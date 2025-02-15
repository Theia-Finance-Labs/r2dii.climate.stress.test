test_that("calculate_net_profits penalizes companies for late build out of low
          carbon technologies if overshoot is increasing", {
  input_data <- tibble::tribble(
    ~company_id, ~company_name, ~baseline, ~late_sudden, ~Baseline_price, ~late_sudden_price, ~net_profit_margin, ~direction, ~overshoot_direction, ~proximity_to_target, ~scenario_geography, ~year, ~emission_factor, ~ald_sector, ~ald_business_unit,
    "1", "laggard_with_overshoot", 100, 150, 10, 10, 0.1, "increasing", "Increasing", 0.5, "Global", 2030, 1, "a_sector", "a_business_unit",
    "2", "laggard_with_no_overshoot", 100, 150, 10, 10, 0.1, "increasing", "Decreasing", 0.5, "Global", 2030, 1, "a_sector", "a_business_unit"
  )

  carbon_data_test <- tibble::tribble(
    ~year, ~model, ~scenario, ~variable, ~unit, ~carbon_tax,
    2030, "GCAM 5.3+ NGFS", "NDC", "Price|Carbon", 10, 10,
  )


  test_shock_year <- 2021
  test_market_passthrough <- 0
  test_financial_stimulus <- 1


  net_profits <- calculate_net_profits(input_data,
    carbon_data = carbon_data_test,
    shock_year = test_shock_year,
    market_passthrough = test_market_passthrough,
    financial_stimulus = test_financial_stimulus
  )

  net_profits_baseline_laggard_with_no_overshoot <- net_profits %>%
    dplyr::filter(.data$company_name == "laggard_with_no_overshoot") %>%
    dplyr::pull(.data$net_profits_baseline)

  net_profits_baseline_climate_laggard_with_overshoot <- net_profits %>%
    dplyr::filter(.data$company_name == "laggard_with_overshoot") %>%
    dplyr::pull(.data$net_profits_baseline)

  net_profits_late_sudden_laggard_with_overshoot <- net_profits %>%
    dplyr::filter(.data$company_name == "laggard_with_overshoot") %>%
    dplyr::pull(.data$net_profits_ls)

  net_profits_late_sudden_laggard_with_no_overshoot <- net_profits %>%
    dplyr::filter(.data$company_name == "laggard_with_no_overshoot") %>%
    dplyr::pull(.data$net_profits_ls)

  testthat::expect_equal(
    net_profits_baseline_laggard_with_no_overshoot,
    net_profits_baseline_climate_laggard_with_overshoot
  )
  testthat::expect_gt(
    net_profits_late_sudden_laggard_with_no_overshoot,
    net_profits_late_sudden_laggard_with_overshoot,
  )
})



test_that("calculate_net_profits does apply a carbon tax on high carbon technologies even with decreasing overshoot", {
  input_data <- tibble::tribble(
    ~company_name, ~company_id, ~baseline, ~late_sudden, ~Baseline_price, ~late_sudden_price, ~net_profit_margin, ~direction, ~overshoot_direction, ~proximity_to_target, ~scenario_geography, ~year, ~emission_factor, ~ald_sector, ~ald_business_unit,
    "laggard_low_carbon_technology", "1", 100, 50, 10, 10, 0.1, "increasing", "Decreasing", 0.5, "Global", 2030, 1, "a_sector", "a_business_unit",
    "laggard_high_carbon_technology", "2", 100, 50, 10, 10, 0.1, "declining", "Decreasing", 0.5, "Global", 2030, 1, "a_sector", "a_business_unit"
  )

  carbon_data_test <- tibble::tribble(
    ~year, ~model, ~scenario, ~variable, ~unit, ~carbon_tax,
    2030, "GCAM 5.3+ NGFS", "NDC", "Price|Carbon", 10, 10,
  )


  test_shock_year <- 2021
  test_market_passthrough <- 0
  test_financial_stimulus <- 1



  net_profits <- calculate_net_profits(input_data,
    carbon_data = carbon_data_test,
    shock_year = test_shock_year,
    market_passthrough = test_market_passthrough,
    financial_stimulus = test_financial_stimulus
  )

  net_profits_baseline_climate_laggard_high_carbon_technology <- net_profits %>%
    dplyr::filter(.data$company_name == "laggard_high_carbon_technology") %>%
    dplyr::pull(.data$net_profits_baseline)

  net_profits_baseline_climate_laggard_low_carbon_technology <- net_profits %>%
    dplyr::filter(.data$company_name == "laggard_low_carbon_technology") %>%
    dplyr::pull(.data$net_profits_baseline)

  net_profits_late_sudden_climate_laggard_high_carbon_technology <- net_profits %>%
    dplyr::filter(.data$company_name == "laggard_high_carbon_technology") %>%
    dplyr::pull(.data$net_profits_ls)

  net_profits_late_sudden_climate_laggard_low_carbon_technology <- net_profits %>%
    dplyr::filter(.data$company_name == "laggard_low_carbon_technology") %>%
    dplyr::pull(.data$net_profits_ls)

  testthat::expect_equal(
    net_profits_baseline_climate_laggard_high_carbon_technology,
    net_profits_baseline_climate_laggard_low_carbon_technology
  )
  testthat::expect_gt(
    net_profits_late_sudden_climate_laggard_low_carbon_technology,
    net_profits_late_sudden_climate_laggard_high_carbon_technology
  )
})


test_that("calculate_net_profits does not apply carbon tax on high
          carbon technologies before shock year", {
  input_data <- tibble::tribble(
    ~company_id, ~company_name, ~baseline, ~late_sudden, ~Baseline_price, ~late_sudden_price, ~net_profit_margin, ~direction, ~overshoot_direction, ~proximity_to_target, ~year, ~emission_factor, ~ald_sector, ~ald_business_unit, ~scenario_geography,
    "1", "high carbon ald_business_unit after shock year", 100, 50, 10, 10, 0.1, "declining", "Increasing", 0, 2030, 1, "a_sector", "a_business_unit", "a_geography"
  )

  carbon_data_test <- tibble::tribble(
    ~year, ~model, ~scenario, ~variable, ~unit, ~carbon_tax,
    2030, "GCAM 5.3+ NGFS", "NDC", "Price|Carbon", 10, 10,
  )


  test_shock_year_early <- 2025
  test_shock_year_late <- 2035
  test_market_passthrough <- 0
  test_financial_stimulus <- 1




  net_profits_early <- calculate_net_profits(input_data,
    carbon_data = carbon_data_test,
    shock_year = test_shock_year_early,
    market_passthrough = test_market_passthrough,
    financial_stimulus = test_financial_stimulus
  )

  net_profits_late <- calculate_net_profits(input_data,
    carbon_data = carbon_data_test,
    shock_year = test_shock_year_late,
    market_passthrough = test_market_passthrough,
    financial_stimulus = test_financial_stimulus
  )

  net_profits_late_sudden_high_carbon_technology_early <- net_profits_early %>%
    dplyr::pull(.data$net_profits_ls)

  net_profits_late_sudden_high_carbon_technology_late <- net_profits_late %>%
    dplyr::pull(.data$net_profits_ls)


  testthat::expect_gt(
    net_profits_late_sudden_high_carbon_technology_late,
    net_profits_late_sudden_high_carbon_technology_early
  )
})


test_that("calculate_net_profits penalizes companies for late build out of low
          carbon technologies", {
  input_data <- tibble::tribble(
    ~company_name, ~baseline, ~late_sudden, ~Baseline_price, ~late_sudden_price, ~net_profit_margin, ~direction, ~overshoot_direction, ~proximity_to_target, ~year,
    "leader", 100, 150, 10, 10, 0.1, "increasing", "Increasing", 1, 2030,
    "laggard", 100, 150, 10, 10, 0.1, "increasing", "Increasing", 0.5, 2030,
  )


  test_shock_year <- 2021

  net_profits <- calculate_net_profits_without_carbon_tax(input_data)

  net_profits_baseline_climate_leader <- net_profits %>%
    dplyr::filter(.data$company_name == "leader") %>%
    dplyr::pull(.data$net_profits_baseline)

  net_profits_baseline_climate_laggard <- net_profits %>%
    dplyr::filter(.data$company_name == "laggard") %>%
    dplyr::pull(.data$net_profits_baseline)

  net_profits_late_sudden_climate_leader <- net_profits %>%
    dplyr::filter(.data$company_name == "leader") %>%
    dplyr::pull(.data$net_profits_ls)

  net_profits_late_sudden_climate_laggard <- net_profits %>%
    dplyr::filter(.data$company_name == "laggard") %>%
    dplyr::pull(.data$net_profits_ls)

  testthat::expect_equal(
    net_profits_baseline_climate_leader,
    net_profits_baseline_climate_laggard
  )
  testthat::expect_gt(
    net_profits_late_sudden_climate_leader,
    net_profits_late_sudden_climate_laggard
  )
})



test_that("a higher market passthrough has a weaker impact on a company's net profits", {
  input_data <- tibble::tribble(
    ~company_id, ~company_name, ~baseline, ~late_sudden, ~Baseline_price, ~late_sudden_price, ~net_profit_margin, ~direction, ~overshoot_direction, ~proximity_to_target, ~year, ~emission_factor, ~ald_sector, ~ald_business_unit, ~scenario_geography,
    "1", "high carbon ald_business_unit after shock year", 100, 50, 10, 10, 0.1, "declining", "Decreasing", 0, 2030, 1, "a_sector", "a_business_unit", "a_geography"
  )

  carbon_data_test <- tibble::tribble(
    ~year, ~model, ~scenario, ~variable, ~unit, ~carbon_tax,
    2030, "GCAM 5.3+ NGFS", "NDC", "Price|Carbon", 10, 10,
  )


  test_shock_year <- 2025
  test_market_passthrough_low <- 0
  test_market_passthrough_high <- 1
  test_financial_stimulus <- 1



  net_profits_low_market_power <- calculate_net_profits(input_data,
    carbon_data = carbon_data_test,
    shock_year = test_shock_year,
    market_passthrough = test_market_passthrough_low,
    financial_stimulus = test_financial_stimulus
  )

  net_profits_high_market_power <- calculate_net_profits(input_data,
    carbon_data = carbon_data_test,
    shock_year = test_shock_year,
    market_passthrough = test_market_passthrough_high,
    financial_stimulus = test_financial_stimulus
  )

  net_profits_low_market_power <- net_profits_low_market_power %>%
    dplyr::pull(.data$net_profits_ls)

  net_profits_high_market_power <- net_profits_high_market_power %>%
    dplyr::pull(.data$net_profits_ls)


  testthat::expect_gt(
    net_profits_high_market_power,
    net_profits_low_market_power
  )
})


test_that("calculate_net_profits does only apply a financial stimulus on low carbon technologies", {
  input_data <- tibble::tribble(
    ~company_id, ~company_name, ~baseline, ~late_sudden, ~Baseline_price, ~late_sudden_price, ~net_profit_margin, ~direction, ~overshoot_direction, ~proximity_to_target, ~scenario_geography, ~year, ~emission_factor, ~ald_sector, ~ald_business_unit,
    "1", "low_carbon_technology_company", 100, 50, 10, 10, 0.1, "increasing", "Decreasing", 0.5, "Global", 2030, 1, "a_sector", "a_business_unit",
    "2", "high_carbon_technology_company", 100, 50, 10, 10, 0.1, "declining", "Decreasing", 0.5, "Global", 2030, 1, "a_sector", "a_business_unit"
  )

  carbon_data_test <- tibble::tribble(
    ~year, ~model, ~scenario, ~variable, ~unit, ~carbon_tax,
    2030, "no_carbon_tax", "no_carbon_tax", "Price|Carbon", 0, 0,
  )


  test_shock_year <- 2021
  test_market_passthrough <- 0
  test_financial_stimulus <- 1.5



  net_profits <- calculate_net_profits(input_data,
    carbon_data = carbon_data_test,
    shock_year = test_shock_year,
    market_passthrough = test_market_passthrough,
    financial_stimulus = test_financial_stimulus
  )

  net_profits_baseline_climate_low_carbon_technology_company <- net_profits %>%
    dplyr::filter(.data$company_name == "low_carbon_technology_company") %>%
    dplyr::pull(.data$net_profits_baseline)

  net_profits_baseline_climate_high_carbon_technology_company <- net_profits %>%
    dplyr::filter(.data$company_name == "high_carbon_technology_company") %>%
    dplyr::pull(.data$net_profits_baseline)

  net_profits_late_sudden_climate_low_carbon_technology_company <- net_profits %>%
    dplyr::filter(.data$company_name == "low_carbon_technology_company") %>%
    dplyr::pull(.data$net_profits_ls)

  net_profits_late_sudden_climate_high_carbon_technology_company <- net_profits %>%
    dplyr::filter(.data$company_name == "high_carbon_technology_company") %>%
    dplyr::pull(.data$net_profits_ls)

  testthat::expect_equal(
    net_profits_baseline_climate_low_carbon_technology_company,
    net_profits_baseline_climate_high_carbon_technology_company
  )
  testthat::expect_gt(
    net_profits_late_sudden_climate_low_carbon_technology_company,
    net_profits_late_sudden_climate_high_carbon_technology_company
  )
})


test_that("calculate_net_profits supports a low carbon technology company more the higher the financial stimulus is", {
  input_data <- tibble::tribble(
    ~company_id, ~company_name, ~baseline, ~late_sudden, ~Baseline_price, ~late_sudden_price, ~net_profit_margin, ~direction, ~overshoot_direction, ~proximity_to_target, ~scenario_geography, ~year, ~emission_factor, ~ald_sector, ~ald_business_unit,
    "1", "low_carbon_technology_company", 100, 50, 10, 10, 0.1, "increasing", "Decreasing", 0.5, "Global", 2030, 1, "a_sector", "a_business_unit"
  )

  carbon_data_test <- tibble::tribble(
    ~year, ~model, ~scenario, ~variable, ~unit, ~carbon_tax,
    2030, "no_carbon_tax", "no_carbon_tax", "Price|Carbon", 0, 0,
  )


  test_shock_year <- 2021
  test_market_passthrough <- 0
  low_test_financial_stimulus <- 1.5
  high_test_financial_stimulus <- 2.5

  net_profits_low_financial_stimulus <- calculate_net_profits(input_data,
    carbon_data = carbon_data_test,
    shock_year = test_shock_year,
    market_passthrough = test_market_passthrough,
    financial_stimulus = low_test_financial_stimulus
  )

  net_profits_high_financial_stimulus <- calculate_net_profits(input_data,
    carbon_data = carbon_data_test,
    shock_year = test_shock_year,
    market_passthrough = test_market_passthrough,
    financial_stimulus = high_test_financial_stimulus
  )

  net_profits_late_sudden_low_financial_stimulus <- net_profits_low_financial_stimulus %>%
    dplyr::pull(.data$net_profits_ls)

  net_profits_late_sudden_high_financial_stimulus <- net_profits_high_financial_stimulus %>%
    dplyr::pull(.data$net_profits_ls)

  testthat::expect_gt(
    net_profits_late_sudden_high_financial_stimulus,
    net_profits_late_sudden_low_financial_stimulus
  )
})
