#how to use paannotate on the whiteley dataset

#start fresh
remove.packages("paannotate")
#installation is weird

#install dependencies first
install.packages(c("BiocManager", "readxl", "openxlsx", "pheatmap", "yaml"))

BiocManager::install(c("edgeR", "limma", "fgsea", "goseq"))

install.packages("INSERT PATH/paannotate_1.0.4.9001", repos=NULL, type="source")
#repos = null means you're installing from a local file
#type=source just means that what you're installing is the package itself instead of a part of one

#reload r session

#activate the package
library(paannotate)
#make sure you have everything
pa_check_setup()

#whiteley stuff

#first big whiteley test
result <- pa_run_whiteley(
  targets = "PA1148",
  target_name = "ExoA",
  output_dir = "~/Downloads/ExoA_sample/big"
)
#^^^^^^if you don't have the whitelely data already downloaded, paannotate will do that for you automatically (checks local cache. if not found, downloads the raw dataset from
#whiteley lab's 2/12/26 github release)
#extracts raw feature-count table, metadata, and data-summary files
#identifies and combines sequencing runs belonging to the same biosample and adds their raw counts before normalization

#for the below examples of pa_run_whiteley, it is not necessary to run all of them to understand what's going on. That would take a very long time

#little whiteley test
result <- pa_run_whiteley(
  targets = "PA1148",
  target_name = "ExoA",
  output_dir = "~/Downloads/ExoA_sample/little",
  use_curated_414 = TRUE
)
#uses a sample 46 bioprojects that have unquestionably identifiable info about medium, temperature, timing, organism, treatment. 

#to be careful about precision
result <- pa_run_whiteley(
  targets = "PA1148",
  target_name = "ExoA",
  output_dir = "~/Downloads/ExoA_sample/neurotic",
  use_curated_414 = TRUE,
  i2 = 30,
  fdr = 0.01,
  rho = 0.5,
  include_engineered = FALSE
  
)

#to be careful about experimental conditions

#to know what a dataset without (FOR EXAMPLE) cipro and tobramycin would look like 
check <- pa_check_whiteley_cohort(
  exclude_filters = list(
    treatment = c("ciprofloxacin", "tobramycin")),
  filter_match = "contains",
  missing_metadata = "exclude"
)

#to know what a dataset with ONLY CONFIRMED cipro and tobramycin would look like (probably more helpful)
check2 <- pa_check_whiteley_cohort(
  filters = list(
    treatment = c("ciprofloxacin", "tobramycin")),
  filter_match = "contains",
  missing_metadata = "exclude"
)


#(just good to have readily available) exclude everything that isn't explicitly confirmed wild-type PAO1 (DIFFERENT FROM include_engineered=FALSE)
check3 <- pa_check_whiteley_cohort(
  filters = list(
    engineered_status = "wild_type"),
  filter_match = "contains",
  missing_metadata = "exclude"
)
View(check$selection)

#in an actual analytic run
result <- pa_run_whiteley(
  targets = "PA1148",
  target_name = "ExoA",
  output_dir = "~/Downloads/ExoA_sample/neurotic_conditions",
  use_curated_414 = TRUE,
  i2 = 30,
  fdr = 0.01,
  rho = 0.5,
  filters = list(engineered_stats = "wild type", country = "Italy"),
  media = c("lb", "M9"),
  contexts = "in vitro"
)
#^^^this is too specific to return anything, but shows what's generally helpful

#for looking at multiple genes at once
result <- pa_run_whiteley(
  targets = c("PA0719", "PA0720", "PA0721", "PA0722", "PA0723", "PA0724", "PA0725", "PA0726", "PA0727", "PA0728"),
  target_name = "ExoA",
  output_dir = "~/Downloads/ExoA_sample/neurotic_conditions",
  use_curated_414 = TRUE,
  i2 = 30,
  fdr = 0.01,
  rho = 0.5
)
##This will lump all of these genes together in analysis and look for pathways and genes that uniformly correlate with ALL of the ones in the selection
result <- pa_run_whiteley(
  targets = c("PA0719", "PA0720", "PA0721", "PA0722", "PA0723", "PA0724", "PA0725", "PA0726", "PA0727", "PA0728"),
  separate = TRUE
  target_name = "ExoA",
  output_dir = "~/Downloads/ExoA_sample/neurotic_conditions",
  use_curated_414 = TRUE,
  i2 = 30,
  fdr = 0.01,
  rho = 0.5
)
#This will run each gene separately and compare between them. more informative but takes WAY longer to run

###ENRICHMENT####

#to enrich (the most important function of the entire package)
result <- pa_run_whiteley(
  targets = c("PA0719", "PA0720", "PA0721", "PA0722", "PA0723", "PA0724", "PA0725", "PA0726", "PA0727", "PA0728"),
  separate = TRUE
  target_name = "ExoA",
  output_dir = "~/Downloads/ExoA_sample/neurotic_conditions",
  use_curated_414 = TRUE,
  i2 = 30,
  fdr = 0.01,
  rho = 0.5,
  enrich = TRUE
)
#outputs the heatmaps and pathway analysis along with everything else that it spits out by default

#to add a new custom pathway (like if you want a heatmap showing correlation b/t specific genes and the pf4 core)

#statement that says what you want to include in the new pathway
pf4_core <- c(
  "PA0719", "PA0720", "PA0721", "PA0722", "PA0723",
  "PA0724", "PA0725", "PA0726", "PA0727", "PA0728"
)

#statement that puts the pathway you just described into the format that the pathway analysis uses. The main argument you care about is set_name b/c that will show up on heatmaps
pf4_membership <- data.frame(
  gene_id = pf4_core,
  database = "CUSTOM",
  ontology = "user_defined",
  set_id = "CUSTOM:PF4_CORE",
  set_name = "Pf4 core genes",
  stringsAsFactors = FALSE
)

#to get the full set of pathways that are already included in paannotate (from kegg, go, uniprot) as something that you can directly mess with
annotations <- fetch_pa_annotations()

#to take your new pathway (which is now in the proper format) and to add it to the list that paannotate uses
annotations$membership <- unique(rbind(
  annotations$membership,
  pf4_membership
))

#to run an enrichment analysis that includes your new pathway
result <- pa_run_whiteley(
  targets = "PA0994",
  target_name = "ExoA",
  output_dir = "~/Downloads/ExoA_sample/new_pathway",
  enrich = TRUE,
  membership = annotations
)

#enrichment_args is super complicated so I'm giving it its own section
#it's the argument that has a bunch of settings that control that enrichment stage of the analysis

#format it like:
enrichment_args = list(
#and then whichever settings you want
)

#the ones anyone should care about are:
#minimum/maximum size
pa_run_whiteley(
  targets = c("PA4468"),
  target_name = "SodA",
  output_dir = "~/Downloads/bollyky_lab_26/late_august/iron_vir_individual/sodA",
  membership = annotations,
  enrich = TRUE,
  enrichment_args = list(
    minimum_size = 5,
    maximum_size = 15
  )
)
#^^ exclude pathways containing fewer than 5 genes in the analyzed dataset and also excludes pathways containing more than 15 genes (might be too broad)

#minimum overlap
pa_run_whiteley(
  targets = c("PA4468"),
  target_name = "SodA",
  output_dir = "~/Downloads/bollyky_lab_26/late_august/iron_vir_individual/sodA",
  membership = annotations,
  enrich = TRUE,
  enrichment_args = list(
    minimum_overlap = 5
  )
)
##^^ there must be at LEAST 5 genes in a given pathway that correlate with the one(s) you chose to target, otherwise pathway is excluded from analysis

#methods
pa_run_whiteley(
  targets = c("PA4468"),
  target_name = "SodA",
  output_dir = "~/Downloads/bollyky_lab_26/late_august/iron_vir_individual/sodA",
  membership = annotations,
  enrich = TRUE,
  enrichment_args = list(
    methods = c("ora", "fgsea")

  )
)
#^^^this is the default. methods chooses the enrichment tests
#ORA asks if any particular pathways are unusually common among the genes that passed whatever selection rules you put in place
#fgsea asks whether the genes in a pathway collectively gather toward the positive or negative end of the correlation, and measures the significance of that collective pattern
#fgsea is what you almost always care about, but it runs both by default just in case. 

#to make sure what counts as being in a given pathway correlates in the same direction with a certain number of genes that make up that pathway
pa_run_whiteley(
  targets = c("PA4468"),
  target_name = "SodA",
  output_dir = "~/Downloads/bollyky_lab_26/late_august/iron_vir_individual/sodA",
  membership = annotations,
  enrich = TRUE,
  enrichment_args = list(
    term_fdr = 0.01,
    global_fdr = 0.01

  )
)
# global asks whether the pathway still stands out when compared against all of the other ones in the analysis
# term asks whether the pathway still stands out when compared against the other pathways of its category 
#GO has "exotoxin biosynthesis" "pyoverdine biosynthesis" "alginate biosynthesis" and groups all "biosynthesis" pathways together. Term differentiates b/t those

#if you want to look specifically at certain pathways, use pa_focus_pathways()
#tell it the pathway to the files you got out of pa_run_whiteley and where you want your new folder to end up

pa_focus_pathways(
  "~/Downloads/bollyky_lab_26/late_august/pf_separate_big/pf_bigger",
  output_dir = "~/Downloads/bollyky_lab_26/late_august/pf_separate_big/pf_bigger/ostress_and_vir_factors_and_motility",
  focus = list(
    Oxidative_stress = c("oxidative stress", "oxid", "H2O2"),
    Virulence_iron = c("pyoverdine", "pyochelin", "siderophore", "iron", "phenazine", "heme"),
    chemotaxis = c("flagell", "chemotaxis", "motility", "pili")
  ),
  preview = FALSE,
  evidence = "supported"
)

#preview = TRUE prevents the function from being run and your files to be immediately downloaded, to save time and to know which pathways actually apply to the terms you search
#focus = list() is where you say the general terms to look out for, specifically, and what you want their overarching categories to be named
#evidence = "supported" just has it filter out everything that isn't found to be significant, based on whatever parameters you set when generating the original data

#This is all that one functionally needs to know to analyze the whiteley data with this package (or in general)
