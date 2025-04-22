/* ASSIGNMENT 1 */
/* SECTION 2 */


--SELECT
/* 1. Write a query that returns everything in the customer table. */

Select customer_id
           , customer_first_name
           , customer_last_name
           , customer_postal_code
  From customer;

/* 2. Write a query that displays all of the columns and 10 rows from the cus- tomer table, 
sorted by customer_last_name, then customer_first_ name. */

Select customer_id
           , customer_first_name
           , customer_last_name
           , customer_postal_code
  From customer
 Order by customer_last_name
                  ,customer_first_name
 Limit 10;

--WHERE
/* 1. Write a query that returns all customer purchases of product IDs 4 and 9. */
-- option 1

Select * 
 From customer_purchases
Where product_id in(4,9);

-- option 2
Select * 
  From customer_purchases
Where product_id =4 or product_id =9;


/*2. Write a query that returns all customer purchases and a new calculated column 'price' (quantity * cost_to_customer_per_qty), 
filtered by vendor IDs between 8 and 10 (inclusive) using either:
	1.  two conditions using AND
	2.  one condition using BETWEEN
*/
-- option 1
Select P.product_name
            ,Cp.*
			,(quantity * cost_to_customer_per_qty) As Price 
 From customer_purchases Cp
 Inner Join product P on Cp.product_id=P.product_id
Where vendor_id in(8,9,10);

-- option 2
Select P.product_name
             ,Cp.*
			 ,(quantity * cost_to_customer_per_qty) As Price 
 From customer_purchases Cp
 Inner Join product P on Cp.product_id=P.product_id
Where vendor_id between 8 and 10;


--CASE
/* 1. Products can be sold by the individual unit or by bulk measures like lbs. or oz. 
Using the product table, write a query that outputs the product_id and product_name
columns and add a column called prod_qty_type_condensed that displays the word “unit” 
if the product_qty_type is “unit,” and otherwise displays the word “bulk.” */

Select product_id
            ,product_name
           , Case  When product_qty_type ='unit' Then 'Unit'
						 Else 'Bulk' End As prod_qty_type_condensed
 From product;

/* 2. We want to flag all of the different types of pepper products that are sold at the market. 
add a column to the previous query called pepper_flag that outputs a 1 if the product_name 
contains the word “pepper” (regardless of capitalization), and otherwise outputs 0. */

Select product_id
            ,product_name
           , Case  When product_qty_type ='unit' Then 'Unit'
						 Else 'Bulk' End As prod_qty_type_condensed
			, Case When INSTR(lower(product_name),'pepper') >1 Then 1
                        Else 0 End  As pepper_flag
 From product;

--JOIN
/* 1. Write a query that INNER JOINs the vendor table to the vendor_booth_assignments table on the 
vendor_id field they both have in common, and sorts the result by vendor_name, then market_date. */

Select V.*       /* Fetch data from Vendor table*/
            ,Vba.*  /* Fetch data from vendor_booth_assignments table*/ 
 From vendor V
            Inner Join vendor_booth_assignments Vba on V.vendor_id=Vba.vendor_id
Order By V.vendor_name
                  ,Vba.market_date ;

/* SECTION 3 */

-- AGGREGATE
/* 1. Write a query that determines how many times each vendor has rented a booth 
at the farmer’s market by counting the vendor booth assignments per vendor_id. */

Select V.vendor_id       /* Fetch data from Vendor table*/
            ,Max(V.vendor_name) As vendor_name
			,Count(1) As Rented_Count
 From vendor V
            Inner Join vendor_booth_assignments Vba on V.vendor_id=Vba.vendor_id
Group by V.vendor_id			
Order By V.vendor_id ;

/* 2. The Farmer’s Market Customer Appreciation Committee wants to give a bumper 
sticker to everyone who has ever spent more than $2000 at the market. Write a query that generates a list 
of customers for them to give stickers to, sorted by last name, then first name. 

HINT: This query requires you to join two tables, use an aggregate function, and use the HAVING keyword. */

Select C.customer_id
            ,Max(C.customer_first_name) As customer_first_name
            ,Max(C.customer_last_name) As customer_last_name
            ,Sum(quantity*cost_to_customer_per_qty) Amount_Spent
  From customer C
              Inner Join customer_purchases Cp on C.customer_id=Cp.customer_id
			  Group by C.customer_id 
Having Sum(quantity*cost_to_customer_per_qty)  > 2000
 Order by customer_last_name
                  ,customer_first_name

--Temp Table
/* 1. Insert the original new_vendor table into a temp.new_vendor and then add a 10th vendor: 
Thomass Superfood Store, a Fresh Focused store, owned by Thomas Rosenthal

HINT: This is two total queries -- first create the table from the original, then insert the new 10th vendor. 
When inserting the new vendor, you need to appropriately align the columns to be inserted 
(there are five columns to be inserted, I've given you the details, but not the syntax) 

-> To insert the new row use VALUES, specifying the value you want for each column:
VALUES(col1,col2,col3,col4,col5) 
*/
DROP TABLE IF EXISTS temp.new_vendor;
CREATE TEMP TABLE new_vendor AS select * from vendor;

Insert into temp.new_vendor(vendor_id,vendor_name,vendor_type,vendor_owner_first_name,vendor_owner_last_name)
VALUES (10,'Thomass Superfood Store', 'Fresh Focused store', 'Thomas','Rosenthal');

Select * from temp.new_vendor;

-- Date
/*1. Get the customer_id, month, and year (in separate columns) of every purchase in the customer_purchases table.

HINT: you might need to search for strfrtime modifers sqlite on the web to know what the modifers for month 
and year are! */

Select customer_id
             ,strftime('%m', market_date) Month
			 ,strftime('%Y', market_date) Year
			 ,market_date
 From customer_purchases Cp;

/* 2. Using the previous query as a base, determine how much money each customer spent in April 2022. 
Remember that money spent is quantity*cost_to_customer_per_qty. 

HINTS: you will need to AGGREGATE, GROUP BY, and filter...
but remember, STRFTIME returns a STRING for your WHERE statement!! */

Select C.customer_id
            ,Max(C.customer_first_name) As customer_first_name
            ,Max(C.customer_last_name) As customer_last_name
           ,Sum(Amount_Spent) As Amount_Spent
From (Select customer_id
                         ,strftime('%m', market_date) Month
			             ,strftime('%Y', market_date) Year
			             ,(quantity*cost_to_customer_per_qty) Amount_Spent
			             ,market_date
              From customer_purchases Cp) A
	                      Inner Join customer C on A.customer_id =C.customer_id
 Where Month ='04'
              And Year ='2022'
			  Group by C.customer_id
			  Order by Amount_Spent;