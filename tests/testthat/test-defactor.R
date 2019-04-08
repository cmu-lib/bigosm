context("test-defactor")

test_that("defactor gets rid of all factors", {
  mapply(function(element, element_name) {
    mapply(function(df, dfname) {
      mapply(function(col, col_name) expect_false(is.factor(col),
        info = sprintf("%s - %s$%s should not be a factor.", element_name, dfname, col_name)), df, names(df))
    }, element, names(element))
  }, boston_osmar, names(boston_osmar))
})
