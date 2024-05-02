use customer_churn_data;
select * from customer_churn_dataset;
alter table customer_churn_dataset rename to customerdetail;
select * from customerdetail;
SELECT
    COUNT(customer_id) AS total_customers,
    sum(CASE WHEN churn_status = 'yes' THEN 1 ELSE 0 END) AS churned_customers,
    (SUM(CASE WHEN churn_status = 'yes' THEN 1 ELSE 0 END) / COUNT(customer_id)) * 100 AS churn_rate
FROM
    customerdetail;
    
select churn_status, COUNT(customer_id) AS total_customers
from customerdetail group by churn_status;

## 5.	Create a query to identify the contract types that are most prone to churn
SELECT contract_type, COUNT(churn_status) AS churn_count
FROM customerdetail
WHERE churn_status = 'yes'
GROUP BY contract_type
ORDER BY churn_count DESC;




select customer_id, age, monthly_charges,
case
   when age>50 then "Old age"
   when age between 31 and 50 then "Mid age"
   else "young age"
   end as age_category
from customerdetail
where age is not null
order by age;

###24.	Create a view to find the customers with the highest monthly charges in each contract type
create view customer_salary as
select customer_id, contract_type, monthly_charges
from ( select customer_id, contract_type, monthly_charges,
ROW_NUMBER() over(PARTITION BY contract_type ORDER BY monthly_charges DESC) as rank_custmers
from customerdetail)
as ranked_customers;

select * from customer_salary;


SELECT 
    contract_type,
    customer_id,
    monthly_charges
FROM customer_salary
WHERE (contract_type, monthly_charges) IN (
    SELECT 
        contract_type,
        MAX(monthly_charges) AS highest_monthly_charge
    FROM customer_salary
    GROUP BY contract_type
);


----error---
create view highestmonthly_charges as 
select 
    customer_id,
    contract_type,
    MAX(monthly_charges) AS highest_monthly_charge
FROM customerdetail
GROUP BY contract_type;

select * from highestmonthly_charges;

SELECT 
    contract_type,
    MAX(monthly_charges) AS highest_monthly_charge
FROM customer_salary
GROUP BY contract_type;

## 25.	Create a view to identify customers who have churned and the average monthly charges compared to the overall average

select customer_id, churn_status, monthly_charges from customerdetail;

create view churncustomers_avgmnthsalary as select customer_id, churn_status, monthly_charges, avg(monthly_charges) as overall_avg
from customerdetail
where (churn_status, monthly_charges) in 
(select 
avg(monthly_charges) as churned_avgmnth_charges
where churn_status='yes');

select* from churncustomers_avgmnthsalary;


select  churn_status, avg(monthly_charges) 
from customerdetail
group by churn_status;

SELECT churn_status, AVG(monthly_charges)
FROM customerdetail
WHERE churn_status = 'yes';

select  avg(monthly_charges) from customerdetail;


## 26.	Create a view to find the customers who have churned and their cumulative total charges over time

create view churnedcustomers_totalcharges as select churn_status, sum(total_charges)
from customerdetail
where churn_status = 'yes';

select * from churnedcustomers_totalcharges;

select churn_status, sum(total_charges)
from customerdetail
where churn_status = 'yes'
;

## 27.	Stored Procedure to Calculate Churn Rate
DELIMITER //
CREATE PROCEDURE CalculateChurnRate()
BEGIN
    DECLARE total_customers INT;
    DECLARE churned_customers INT;
    DECLARE churn_rate DECIMAL(5,2);

    -- Get the total number of customers
    SELECT COUNT(*) INTO total_customers FROM customerdetail;

    -- Get the number of churned customers
    SELECT COUNT(*) INTO churned_customers FROM customerdetail WHERE churn_status = 'yes';

    -- Calculate churn rate
    IF total_customers > 0 THEN
        SET churn_rate = (churned_customers / total_customers) * 100;
    ELSE
        SET churn_rate = 0;
    END IF;

    -- Display or use the churn rate
    SELECT churn_rate AS 'Churn Rate (%)';
END //
DELIMITER ;

show procedure status ;
select * from customer_churn_data;
select * from  CalculateChurnRate;


