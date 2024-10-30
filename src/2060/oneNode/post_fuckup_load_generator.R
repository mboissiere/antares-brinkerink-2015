hourly_S1_load_tbl <- read.table(".\\src\\2060\\oneNode\\hourly_S1_2060_load.txt",
                                        header = TRUE,
                                        sep = ";",
                                        dec = ".",
                                        stringsAsFactors = FALSE,
                                        encoding = "UTF-8",
                                        check.names = FALSE,
                                        fill = TRUE
)
hourly_S1_load_tbl <- as_tibble(hourly_S1_load_tbl)

saveRDS(hourly_S1_load_tbl, ".\\src\\2060\\oneNode\\hourly_S1_load_tbl.rds")


hourly_S2_load_tbl <- read.table(".\\src\\2060\\oneNode\\hourly_S2_2060_load.txt",
                                 header = TRUE,
                                 sep = ";",
                                 dec = ".",
                                 stringsAsFactors = FALSE,
                                 encoding = "UTF-8",
                                 check.names = FALSE,
                                 fill = TRUE
)
hourly_S2_load_tbl <- as_tibble(hourly_S2_load_tbl)

saveRDS(hourly_S2_load_tbl, ".\\src\\2060\\oneNode\\hourly_S2_load_tbl.rds")


hourly_S3_load_tbl <- read.table(".\\src\\2060\\oneNode\\hourly_S3_2060_load.txt",
                                 header = TRUE,
                                 sep = ";",
                                 dec = ".",
                                 stringsAsFactors = FALSE,
                                 encoding = "UTF-8",
                                 check.names = FALSE,
                                 fill = TRUE
)
hourly_S3_load_tbl <- as_tibble(hourly_S3_load_tbl)

saveRDS(hourly_S3_load_tbl, ".\\src\\2060\\oneNode\\hourly_S3_load_tbl.rds")


hourly_S4_load_tbl <- read.table(".\\src\\2060\\oneNode\\hourly_S4_2060_load.txt",
                                 header = TRUE,
                                 sep = ";",
                                 dec = ".",
                                 stringsAsFactors = FALSE,
                                 encoding = "UTF-8",
                                 check.names = FALSE,
                                 fill = TRUE
)
hourly_S4_load_tbl <- as_tibble(hourly_S4_load_tbl)

saveRDS(hourly_S4_load_tbl, ".\\src\\2060\\oneNode\\hourly_S4_load_tbl.rds")