# perturbatr: analysis of high-throughput gene perturbation screens
#
# Copyright (C) 2018 Simon Dirmeier
#
# This file is part of perturbatr
#
# perturbatr is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# perturbatr is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with perturbatr. If not, see <http://www.gnu.org/licenses/>.


#' Create model data for an hierarchical model
#'
#' @docType methods
#' @rdname setModelData-methods
#'
#' @import tibble
#'
#' @param obj  an data set
#' @param drop  boolean if genes that are not found in every Condition should
#'  be dropped
#' @param weights  a numeric vector used as weights for the single
#'  perturbations
#'
#' @return  returns an \code{PerturbationData} object
#'
setGeneric(
  "setModelData",
  function(obj, drop=TRUE, weights=1) { standardGeneric("setModelData") }
)


#' @rdname setModelData-methods
#' @aliases setModelData,PerturbationData-method
#' @import tibble
#' @importFrom dplyr select filter group_by mutate ungroup
#' @importFrom rlang .data
setMethod(
  "setModelData",
  signature = signature(obj="PerturbationData"),
  function(obj, drop=TRUE, weights=1)
  {
    hm.mat <- dataSet(obj) %>%
      dplyr::mutate(Weight = as.double(weights)) %>%
      dplyr::filter(!is.na(.data$GeneSymbol)) %>%
      dplyr::filter(.data$Control != 1) %>%
      dplyr::filter(!is.na(.data$Readout))

    hm.mat$Condition  <- as.factor(hm.mat$Condition)
    hm.mat$GeneSymbol <- as.factor(hm.mat$GeneSymbol)

    if (drop)
    {
      vir.cnt <- leuniq(hm.mat$Condition)
      hm.mat <- dplyr::group_by(hm.mat, .data$GeneSymbol) %>%
        dplyr::mutate("drop" = (leuniq(.data$Condition) != vir.cnt)) %>%
        dplyr::ungroup() %>%
        dplyr::filter(!.data$drop) %>%
        dplyr::select(-.data$drop)
    }

    hm.mat
  }
)
