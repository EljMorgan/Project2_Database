CREATE DATABASE rd_index_project_week_2;
USE rd_index_project_week_2;

CREATE TABLE IF NOT EXISTS country(
 ID INT NOT NULL,
 country_code varchar(50),
 PRIMARY KEY(country_code)
);
INSERT INTO country
(ID, country_code)
VALUES (1,'GBR'),
(2, 'MLT'),
(3, 'DEU'),
(4, 'FRA'),
(5, 'ROU'),
(6, 'SVN'),
(7, 'CZE');
CREATE TABLE IF NOT EXISTS journal_articles(
 id int,
 country_code varchar(50),
 year YEAR,
 data_point FLOAT,
 index c_code(country_code),
 foreign key (country_code)
 references country(country_code)
);
CREATE TABLE IF NOT EXISTS researchers_rd(
 country_code char(20),
 year YEAR,
 data_point FLOAT,
 index c_code(country_code),
 foreign key (country_code)
 references country(country_code)
);
CREATE TABLE IF NOT EXISTS rd_expenditure(
 country_code char(20),
 year YEAR,
 data_point FLOAT,
 index c_code(country_code),
 foreign key (country_code)
 references country(country_code)
);
CREATE TABLE IF NOT EXISTS tax_subsidy(
 country_code char(20),
 year YEAR,
 data_point FLOAT,
  index c_code(country_code),
 foreign key (country_code)
 references country(country_code));

CREATE TEMPORARY TABLE journal_articles_2
SELECT country_code, year,
ROUND((data_point - (SELECT MIN(data_point) FROM tax_subsidy))/((SELECT MAX(data_point) FROM tax_subsidy) - ((SELECT MIN(data_point) FROM tax_subsidy))),5) AS norm_ind
FROM tax_subsidy;

CREATE TEMPORARY TABLE rd_expenditure_2
SELECT country_code, year,
ROUND((data_point - (SELECT MIN(data_point) FROM tax_subsidy))/((SELECT MAX(data_point) FROM tax_subsidy) - ((SELECT MIN(data_point) FROM tax_subsidy))),5) AS norm_ind
FROM tax_subsidy;

CREATE TEMPORARY TABLE researchers_rd_2
SELECT country_code, year,
ROUND((data_point - (SELECT MIN(data_point) FROM tax_subsidy))/((SELECT MAX(data_point) FROM tax_subsidy) - ((SELECT MIN(data_point) FROM tax_subsidy))),5) AS norm_ind
FROM tax_subsidy;

CREATE TEMPORARY TABLE tax_subsidy_2
SELECT country_code, year,
ROUND((data_point - (SELECT MIN(data_point) FROM tax_subsidy))/((SELECT MAX(data_point) FROM tax_subsidy) - ((SELECT MIN(data_point) FROM tax_subsidy))),5) AS norm_ind
FROM tax_subsidy;

CREATE TEMPORARY TABLE joined_indicators_4
SELECT journal_articles_2.country_code, journal_articles_2.year, journal_articles_2.norm_ind, 
rd_expenditure_2.norm_ind AS norm_ind2,
researchers_rd_2.norm_ind AS norm_ind3, 
tax_subsidy_2.norm_ind AS norm_ind4
FROM journal_articles_2 
LEFT join rd_expenditure_2
on journal_articles_2.country_code=rd_expenditure_2.country_code AND journal_articles_2.year=rd_expenditure_2.year
left join researchers_rd_2
on rd_expenditure_2.country_code=researchers_rd_2.country_code AND rd_expenditure_2.year=researchers_rd_2.year
left join tax_subsidy_2
on researchers_rd_2.country_code=tax_subsidy_2.country_code AND researchers_rd_2.year=tax_subsidy_2.year
;

CREATE TABLE final_index (country_code VARCHAR(25), year year, index_ FLOAT);

INSERT INTO final_index
SELECT country_code, year, ROUND(((norm_ind + norm_ind2 + norm_ind3 +norm_ind4)/4),5) AS index_1 
FROM joined_indicators_4;
