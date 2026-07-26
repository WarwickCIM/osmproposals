#' Scrape votes for tagging proposals
#'
#' Given a vector of urls, scrapes the tagging proposals to retrieve all the votes received.
#'
#' @param urls a string containing the tagging proposal to retrieve voting history from.
#'
#' @returns a dataframe with the following columns:
#' - `fullurl`: (string) the URL to the tagging proposal wiki page.
#' - `votes_raw`: (string) the raw text describing the vote.
#' - `vote`: (factor) vote (Approve, Oppose, Abstain, Other), based on the svg starting the `title` attribute of the vote icon's link.
#' - `user`: (factor) voter's username.
#' - `date_vote`: (POSIXct, UTC) date and time the vote was cast.
#'
#' @export
#'
#' @examples
#' proposal_votes <- get_proposals_votes('https://wiki.openstreetmap.org/wiki/Proposal:Electricity')
#'
#' proposal_votes
#'
get_proposals_votes <- function(urls) {
  votes_df <- data.frame()
  pb <- cli::cli_progress_bar("Scraping proposals", total = length(urls))

  # Only <li> nodes that come after the "Voting" heading AND whose very
  # first child element is the vote icon (<span typeof="mw:File">).
  # Requiring the icon to be the first child is what:
  #  1. Excludes the "Instructions for voting" votes inside a table.
  #  2. Excludes footer/navigation <li>s picked up by `following::` (no icon).
  #  3. Excludes nested/threaded reply <li>s inside a vote (the icon
  #     belongs only to the outer vote <li>), which is what was causing
  #     multi-paragraph / threaded votes to be counted twice.
  vote_li_xpath <- "//*[@id='Voting']/following::li[*[1][self::span][@typeof='mw:File']][not(ancestor::table)]"

  for (url in urls) {
    result <- tryCatch(
      {
        page <- rvest::read_html(url)
        vote_nodes <- rvest::html_elements(page, xpath = vote_li_xpath)

        if (length(vote_nodes) == 0) {
          stop("No votes found with the expected structure")
        }

        votes_raw <- rvest::html_text2(vote_nodes)

        # Vote type: read straight off the icon's <a title="..."> attribute,
        # e.g. "I approve this proposal" / "I oppose this proposal" /
        # "I abstain from voting but have comments". This is far more robust
        # than pattern-matching the surrounding free text, and picks up
        # non-standard vote types (see Template:Vote) as "Other" instead of
        # silently dropping them.
        icon_title <- purrr::map_chr(vote_nodes, function(li) {
          a_node <- rvest::html_element(
            li,
            xpath = ".//span[1][@typeof='mw:File']/a[1]"
          )
          if (is.na(a_node)) {
            return(NA_character_)
          }
          rvest::html_attr(a_node, "title")
        })

        vote <- dplyr::case_when(
          stringr::str_detect(
            icon_title,
            stringr::regex("approve", ignore_case = TRUE)
          ) ~ "Approve",
          stringr::str_detect(
            icon_title,
            stringr::regex("oppose", ignore_case = TRUE)
          ) ~ "Oppose",
          stringr::str_detect(
            icon_title,
            stringr::regex("abstain", ignore_case = TRUE)
          ) ~ "Abstain",
          !is.na(icon_title) ~ "Other",
          TRUE ~ NA_character_
        )

        # Username: the LAST link inside the <li> whose title starts with
        # "User:" (as opposed to "User talk:"). Taking the last such link
        # (rather than the first) protects against votes whose comment body
        # happens to mention another user before the actual signature.
        # Works for both existing user pages and red-linked ones.
        user <- purrr::map_chr(vote_nodes, function(li) {
          user_links <- rvest::html_elements(
            li,
            xpath = ".//a[starts-with(@title, 'User:')]"
          )
          if (length(user_links) == 0) {
            return(NA_character_)
          }
          last_link <- user_links[[length(user_links)]]
          stringr::str_trim(rvest::html_text2(last_link))
        })

        # Date/time of the vote: taken from the signature timestamp that
        # ~~~~ inserts, e.g. "15:26, 19 April 2020 (UTC)"
        date_vote_chr <- stringr::str_extract(
          votes_raw,
          "\\d{1,2}:\\d{2},\\s*\\d{1,2}\\s+[A-Za-z]+\\s+\\d{4}\\s*\\(UTC\\)"
        )
        date_vote <- as.POSIXct(
          date_vote_chr,
          format = "%H:%M, %d %B %Y (UTC)",
          tz = "UTC"
        )

        data.frame(
          url = url,
          votes_raw = votes_raw,
          vote = vote,
          user = user,
          date_vote = date_vote
        )
      },
      error = function(e) {
        message(sprintf("Could not scrape %s: %s", url, e$message))
        data.frame(
          url = url,
          votes_raw = NA_character_,
          vote = NA_character_,
          user = NA_character_,
          date_vote = as.POSIXct(NA)
        )
      }
    )

    votes_df <- dplyr::bind_rows(votes_df, result)
    cli::cli_progress_update()
    Sys.sleep(runif(1, min = 5, max = 30))
  }

  votes_df <- votes_df |>
    dplyr::mutate(
      vote = as.factor(vote),
      user = as.factor(user)
    ) |>
    tibble::as_tibble()

  cli::cli_progress_done()
  return(votes_df)
}
