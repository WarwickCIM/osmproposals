#' Scrape stats from tagging proposals
#'
#' Given a vector of urls, scrapes the tagging proposals to retrieve statistics and stores them into a dataframe.
#'
#' @param urls a string containing the tagging proposal to retrieve details from.
#' @param verbose a boolean to print the URL in the console.
#'
#' @returns a dataframe with the following columns:
#' - `url`: the URL of the tagging proposal.
#' - `page_creator`: the username who created the page.
#' - `date_of_page_creation`: the date in which the page was created.
#' - `latest_editor`: the username who last edited the page.
#' - `date_of_latest_edit`: date in which the page was last updated.
#' - `total_number_of_edits`: number of total times that the page has been edited.
#' - `total_number_of_disctinct_authors`: number of distinct users who have edited the page.
#' @export
#'
#' @examples
#' proposals_info <- get_proposals_info('https://wiki.openstreetmap.org/wiki/Proposal:Electricity')
#'
#' proposals_info
#'
get_proposals_info <- function(
  urls,
  verbose = FALSE
) {
  cli::cli_h1("Retrieving proposals' information")

  # Create empty dataframe to append details to it.
  proposals_info <- data.frame()

  cli::cli_progress_bar("Webscrapping", total = length(urls))

  # Make sure that only urls containing tagging proposals are scraped.
  url <- url[grepl("Proposal", url, ignore.case = FALSE)]

  for (url in urls) {
    if (verbose == TRUE) {
      print(url)
    }

    url_info <- paste0(url, "?action=info")

    result <- tryCatch(
      {
        tables <- rvest::read_html(url_info) |>
          rvest::html_elements("table") |>
          rvest::html_table()

        # Function to rearrange the date and time.
        # Dates are stored as hh:mm, dmy, so we want to swap their values to be able to
        # convert them to date format.
        rearrange_datetime <- function(datetime_string) {
          stringr::str_replace(
            datetime_string,
            "^([0-9]{2}:[0-9]{2}), (.+)$",
            "\\2 \\1"
          )
        }

        # Page info contains several tables. We are only interested in the third one,
        # containing edit history.
        table_edit_history <- tables[[3]] |>
          dplyr::mutate(
            X1 = stringr::str_to_lower(X1),
            X1 = stringr::str_replace_all(X1, " ", "_")
          ) |>
          tidyr::pivot_wider(names_from = X1, values_from = X2) |>
          dplyr::mutate(across(starts_with("date"), rearrange_datetime)) |>
          dplyr::mutate(across(starts_with("date"), lubridate::dmy_hm)) |>
          dplyr::mutate(
            page_creator = stringr::str_remove_all(
              page_creator,
              ' \\(talk \\| contribs\\)'
            ),
          ) |>
          dplyr::mutate(
            latest_editor = stringr::str_remove_all(
              latest_editor,
              " \\(.*\\)"
            )
          ) |>
          dplyr::mutate(url = url, .before = 1) |>
          dplyr::mutate(
            total_number_of_edits = as.numeric(total_number_of_edits),
            total_number_of_distinct_authors = as.numeric(
              total_number_of_distinct_authors
            )
          ) |>
          dplyr::select(!dplyr::starts_with("recent"))

        proposal_history <- table_edit_history

        proposals_info <- proposals_info |>
          dplyr::bind_rows(proposal_history)
      },
      error = function(e) {
        #message(sprintf("Could not scrape %s: %s", url, e$message))
        cli::cli_alert_warning("Could not scrape {url}: {e$message}")
        NULL
      }
    )

    cli::cli_progress_update()
  }

  proposals_info <- proposals_info |>
    dplyr::mutate(page_creator = as.factor(page_creator)) |>
    dplyr::mutate(latest_editor = as.factor(latest_editor))

  return(proposals_info)
}
