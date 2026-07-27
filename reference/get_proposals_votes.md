# Scrape votes for tagging proposals

Given a vector of urls, scrapes the tagging proposals to retrieve all
the votes received.

## Usage

``` r
get_proposals_votes(urls)
```

## Arguments

- urls:

  a string containing the tagging proposal to retrieve voting history
  from.

## Value

a dataframe with the following columns:

- `fullurl`: (string) the URL to the tagging proposal wiki page.

- `votes_raw`: (string) the raw text describing the vote.

- `vote`: (factor) vote (Approve, Oppose, Abstain, Other), based on the
  svg starting the `title` attribute of the vote icon's link.

- `user`: (factor) voter's username.

- `date_vote`: (POSIXct, UTC) date and time the vote was cast.

## Examples

``` r
proposal_votes <- get_proposals_votes('https://wiki.openstreetmap.org/wiki/Proposal:Electricity')

proposal_votes
#> # A tibble: 23 × 5
#>    url                                 votes_raw vote  user  date_vote          
#>    <chr>                               <chr>     <fct> <fct> <dttm>             
#>  1 https://wiki.openstreetmap.org/wik… I approv… Appr… Luke  2021-01-18 19:21:00
#>  2 https://wiki.openstreetmap.org/wik… I approv… Appr… Gaus… 2021-01-18 19:34:00
#>  3 https://wiki.openstreetmap.org/wik… I approv… Appr… Dr C… 2021-01-18 20:52:00
#>  4 https://wiki.openstreetmap.org/wik… I oppose… Oppo… NA    NA                 
#>  5 https://wiki.openstreetmap.org/wik… I approv… Appr… Blen… 2021-01-19 14:17:00
#>  6 https://wiki.openstreetmap.org/wik… I approv… Appr… Mar … 2021-01-20 17:27:00
#>  7 https://wiki.openstreetmap.org/wik… I have c… Abst… Jona… 2021-01-21 08:13:00
#>  8 https://wiki.openstreetmap.org/wik… I approv… Appr… Nori… 2021-01-21 12:25:00
#>  9 https://wiki.openstreetmap.org/wik… I approv… Appr… Nanou 2021-01-21 12:28:00
#> 10 https://wiki.openstreetmap.org/wik… I approv… Appr… Andr… 2021-01-21 12:28:00
#> # ℹ 13 more rows
```
