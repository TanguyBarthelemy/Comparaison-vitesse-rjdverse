library("aws.s3")
library("TBox")
library("dplyr")

BUCKET <- "tbarthelemy"
FILE_KEY_S3 <- "data/time.csv"

time_total <-
    aws.s3::s3read_using(
        FUN = TBox::get_data,
        object = FILE_KEY_S3,
        bucket = BUCKET,
        opts = list("region" = "")
    )

time_total <- time_total |>
    filter(!is.na(rjd3x13))

TBox::write_data(time_total, "output/time.csv")
