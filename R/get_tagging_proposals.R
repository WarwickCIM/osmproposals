#' Retrieve a list of tagging proposals
#'
#' Retrieves all tagging proposals in OSM's wiki by querying mediawiki's API and provides basic metadata.
#'
#' @param statuses a string or vector containing proposal's statuses to look for.
#' @param max_items a integer specifiying the the maximum number of members to retrieve for each category. Set to 5 by default.
#' @param info a boolean. Specifies whether to retrieve or not proposals' stats. Set TRUE by default.
#' @param voting_summary a boolean. Specifies whether to retrieve or not proposals' voting summary. Set TRUE by default.
#' @param file a string containing the file path to store the dataset.
#'
#' @returns a dataframe containing tagging proposals and associated metadata (see [`proposals`](proposals.html) for a description of its metadata).
#' @export
#'
#' @examples
#' proposals <- get_tagging_proposals("Proposed")
#' head(proposals)
#'
get_tagging_proposals <- function(
  statuses = c("Rejected", "Approved", "Proposed"),
  max_items = 5,
  info = TRUE,
  voting_summary = TRUE,
  file = NULL
) {
  proposals_df <- data.frame(
    title = character(),
    sortkeyprefix = character(),
    timestamp = character(),
    status = character()
  )

  cli::cli_h1("Retrieving proposals by status")

  cli::cli_progress_bar("Retrieving proposals by status")

  for (status in statuses) {
    cli::cli_text(paste("Retrieving", status, "proposals"))

    tmp_proposals <- WikipediR::pages_in_category(
      domain = "wiki.openstreetmap.org/",
      categories = paste0("Proposals with \"", status, "\" status"),
      type = "page",
      properties = c("title", "sortkeyprefix", "timestamp"),
      clean_response = TRUE,
      limit = max_items
    )

    # Store proposal's statuses.
    tmp_proposals$status <- status

    if ("ns" %in% colnames(tmp_proposals)) {
      tmp_proposals <- dplyr::select(tmp_proposals, -ns)
    }

    proposals_df <- rbind(proposals_df, tmp_proposals)

    # Some cleanup!
    rm(tmp_proposals)

    cli::cli_progress_update()
  }

  # Robustness: make sure that only proposals are captured.

  # Remove pages that are not proposals per se, but a collection of proposals
  # grouped by year.
  proposals_df <- proposals_df |>
    dplyr::filter(stringr::str_starts(title, "Approved", negate = TRUE)) |>
    # Prevent capturing pages that are not related to proposals (e.g. some users
    # who have made a tagging proposal may use the category in their wiki pages,
    # and we do not want to capture this)
    dplyr::filter(stringr::str_detect(title, "Proposal"))

  total_proposals <- nrow(proposals_df)

  cli::cli_alert_success("Retrieved {total_proposals} proposals.")

  ## Retrieve details -----------------
  # The previous just provides very basic info: title, sortkeyprefix and timestamp. We need to query
  # each page to get their details.

  cli::cli_h1("Retrieving proposals' details")

  cli::cli_progress_bar("Retrieving details", total = total_proposals)

  # Create empty dataframe
  info_df <- data.frame(
    title = character(),
    contentmodel = character(),
    pagelanguage = character(),
    pagelanguagehtmlcode = character(),
    pagelanguagedir = character(),
    touched = character(),
    lastrevid = integer(),
    length = integer(),
    fullurl = character(),
    editurl = character(),
    canonicalurl = character()
  )

  for (i in 1:nrow(proposals_df)) {
    tmp_info <- WikipediR::page_info(
      domain = "wiki.openstreetmap.org/",
      page = proposals_df$title[i],
      properties = c("url"),
      clean_response = TRUE
    )

    if (length(tmp_info) != 0) {
      tmp_info <- dplyr::bind_rows(tmp_info[[1]])

      # if ("touched" %in% colnames(tmp_info) == FALSE) {
      #   tmp_info$touched <- NA
      # }
      #
      # tmp_info <- select(tmp_info,
      #                    # int,
      #                    ns, title,
      #                    contentmodel,
      #                    pagelanguage,
      #                    pagelanguagehtmlcode,
      #                    pagelanguagedir,
      #                    touched,
      #                    lastrevid,
      #                    length,
      #                    fullurl,
      #                    editurl,
      #                    canonicalurl)

      # info_df <- rbind(info_df, tmp_info)
      info_df <- dplyr::bind_rows(info_df, tmp_info)
    }

    cli::cli_progress_update()
  }

  proposals_df <- proposals_df |>
    dplyr::left_join(info_df, by = "title") |>
    dplyr::select(
      status,
      title,
      sortkeyprefix,
      timestamp,
      pagelanguage,
      touched,
      length,
      fullurl,
      editurl,
      pageid
    ) |>
    dplyr::mutate(
      timestamp = lubridate::ymd_hms(timestamp),
      pagelanguage = as.factor(pagelanguage),
      touched = lubridate::ymd_hms(touched)
    )

  cli::cli_alert_success("Retrieved details to {total_proposals} proposals.")

  if (info == TRUE) {
    proposals_info <- get_proposals_info(proposals_df$fullurl)

    proposals_df <- proposals_df |>
      dplyr::left_join(proposals_info, dplyr::join_by('fullurl' == 'url'))
  }

  if (voting_summary == TRUE) {
    voting_summary <- get_voting_summary(proposals_df$fullurl)

    proposals_df <- proposals_df |>
      dplyr::left_join(voting_summary, dplyr::join_by('fullurl' == 'url'))
  }

  if (!is.null(file)) {
    write.csv(proposals_df, file)
  }

  proposals_df <- tibble::as_tibble(proposals_df)

  return(proposals_df)
}
