context("test-defactor")

test_that("defactor gets rid of all factors", {
  defactored_osmar <- defactor(boston_osmar)

  expect_is(defactored_osmar, "defactored_osmar")

  mapply(function(element, element_name) {
    mapply(function(df, dfname) {
      mapply(function(col, col_name) expect_false(is.factor(col),
        info = sprintf("%s - %s$%s should not be a factor.", element_name, dfname, col_name)), df, names(df))
    }, element, names(element))
  }, defactored_osmar, names(defactored_osmar))
})
