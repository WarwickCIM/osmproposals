# Scrape stats from tagging proposals

Given a vector of urls, scrapes the tagging proposals to retrieve
statistics and stores them into a dataframe.

## Usage

``` r
get_proposals_info(urls, verbose = FALSE)
```

## Arguments

- urls:

  a string containing the tagging proposal to retrieve details from.

- verbose:

  a boolean to print the URL in the console.

## Value

a dataframe with the following columns:

- `url`: the URL of the tagging proposal.

- `page_creator`: the username who created the page.

- `date_of_page_creation`: the date in which the page was created.

- `latest_editor`: the username who last edited the page.

- `date_of_latest_edit`: date in which the page was last updated.

- `total_number_of_edits`: number of total times that the page has been
  edited.

- `total_number_of_disctinct_authors`: number of distinct users who have
  edited the page.

## Examples

``` r
proposals_info <- get_proposals_info('https://wiki.openstreetmap.org/wiki/Proposal:Electricity')
#> 
#> ── Retrieving proposals' information ───────────────────────────────────────────
#> Error in as.character(x): cannot coerce type 'closure' to vector of type 'character'

proposals_info
#> Error: object 'proposals_info' not found
```
