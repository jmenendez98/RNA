#!/usr/bin/env Rscript

# Load necessary libraries
suppressMessages(library(DESeq2))
suppressMessages(library(EnhancedVolcano))
suppressMessages(library(optparse))

# Define command line options
option_list <- list(
  make_option(c("-c", "--count_matrix"), type="character", help="Path to the count matrix file"),
  make_option(c("-s", "--sample_info"), type="character", help="Path to the sample information file"),
  make_option(c("-o", "--output_prefix"), type="character", help="Path to the output file"),
  make_option(c("-d", "--design_formula"), type="character", default="~ condition", help="Design formula for DESeq2 [default: ~ condition]")
)

# Parse command line options
opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

cat(opt$count_matrix)
cat(opt$sample_info)
cat(opt$count_matrix)

# Check if all required arguments are provided
if (is.null(opt$count_matrix) || is.null(opt$sample_info) || is.null(opt$output_prefix)) {
  print_help(opt_parser)
  stop("Please provide the required arguments.", call.=FALSE)
}

# Load the count matrix
count_matrix <- read.csv(opt$count_matrix, sep="\t", row.names=1, check.names=FALSE)

# Load the sample information
sample_info <- read.csv(opt$sample_info, sep="\t", row.names=1, check.names=FALSE)
sample_info$condition <- factor(sample_info$condition)

# Ensure the row names of sample_info match the column names of the count matrix
if (!all (rownames(sample_info) %in% colnames(count_matrix))) {
  stop("Sample information row names do not match count matrix column names.", call.=FALSE)
}

# Create a DESeq2 dataset
dds <- DESeqDataSetFromMatrix(countData = count_matrix, colData = sample_info, design = as.formula(opt$design_formula))

# DESeq2 Prefiltering
smallestGroupSize <- 3
keep <- rowSums(counts(dds) >= 10) >= smallestGroupSize
dds <- dds[keep,]

# Run the DESeq2 differential expression analysis
dds <- DESeq(dds)

# Get the results
res <- results(dds)

# Save the results to a file
csv_output <- paste(opt$output_prefix, ".csv", sep="")
write.csv(as.data.frame(res), file = csv_output)

# Create volcano plot and save to a file
volcano_png <- paste(opt$output_prefix, "_volcano.png", sep="")
png(volcano_png)
EnhancedVolcano(res, lab = rownames(res), x = 'log2FoldChange', y = 'pvalue')
dev.off()

# Print a message to indicate the script has finished
cat("Differential expression analysis complete. Results saved to", csv_output, "\n")
cat("Volcano Plot png saved to", volcano_png, "\n")