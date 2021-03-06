% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/grouped_summary.R
\name{grouped_summary}
\alias{grouped_summary}
\title{Descriptive statistics for multiple variables for all grouping
variable levels}
\usage{
grouped_summary(
  data,
  grouping.vars,
  measures = NULL,
  measures.type = "numeric",
  topcount.long = FALSE,
  k = 2L,
  ...
)
}
\arguments{
\item{data}{Dataframe from which variables need to be taken.}

\item{grouping.vars}{A list of grouping variables. Please use unquoted
arguments (i.e., use \code{x} and not \code{"x"}).}

\item{measures}{List variables for which summary needs to computed. If not
specified, all variables of type specified in the argument \code{measures.type}
will be used to calculate summaries. \strong{Don't} explicitly set
\code{measures.type = NULL} in function call, which will produce an error
because the function will try to find a column in a dataframe named "NULL".}

\item{measures.type}{A character indicating whether summary for \emph{numeric}
("numeric") or \emph{factor/character} ("factor") variables is expected
(Default: \code{measures.type = "numeric"}). This function can't be used for
both numeric \strong{and} variables simultaneously.}

\item{topcount.long}{If \code{measures.type = factor}, you can get the top counts
in long format for plotting purposes. (Default: \code{topcount.long = FALSE}).}

\item{k}{Number of digits.}

\item{...}{Currently ignored.}
}
\value{
Dataframe with descriptive statistics for numeric variables (n, mean,
sd, median, min, max).
}
\description{
Descriptive statistics for multiple variables for all grouping
variable levels
}
\examples{
# for reproducibility
set.seed(123)

# another possibility
groupedstats::grouped_summary(
  data = iris,
  grouping.vars = Species,
  measures = Sepal.Length:Petal.Width,
  measures.type = "numeric"
)

# if no measures are chosen, all relevant columns will be summarized
groupedstats::grouped_summary(
  data = ggplot2::msleep,
  grouping.vars = vore,
  measures.type = "factor"
)

# for factors, you can also convert the dataframe to a long format with counts
groupedstats::grouped_summary(
  data = ggplot2::msleep,
  grouping.vars = c(vore),
  measures = c(genus:order),
  measures.type = "factor",
  topcount.long = TRUE
)
}
