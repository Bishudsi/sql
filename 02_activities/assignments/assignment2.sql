/* ASSIGNMENT 2 */
/* SECTION 2 */

-- COALESCE
/* 1. Our favourite manager wants a detailed long list of products, but is afraid of tables! 
We tell them, no problem! We can produce a list with all of the appropriate details. 

Using the following syntax you create our super cool and not at all needy manager a list:

SELECT 
product_name || ', ' || product_size|| ' (' || product_qty_type || ')'
FROM product

But wait! The product table has some bad data (a few NULL values). 
Find the NULLs and then using COALESCE, replace the NULL with a 
blank for the first problem, and 'unit' for the second problem. 

HINT: keep the syntax the same, but edited the correct components with the string. 
The `||` values concatenate the columns into strings. 
Edit the appropriate columns -- you're making two edits -- and the NULL rows will be fixed. 
All the other rows will remain the same.) */


Select product_name || ', ' || coalesce(product_size,NULL,'')|| ' (' || coalesce(product_qty_type,NULL,'unit') || ')' As Product_List
 From product;


--Windowed Functions
/* 1. Write a query that selects from the customer_purchases table and numbers each customer’s  
visits to the farmer’s market (labeling each market date with a different number). 
Each customer’s first visit is labeled 1, second visit is labeled 2, etc. 

You can either display all rows in the customer_purchases table, with the counter changing on
each new market date for each customer, or select only the unique market dates per customer 
(without purchase details) and number those visits. 
HINT: One of these approaches uses ROW_NUMBER() and one uses DENSE_RANK(). */

 Select Cp.*
            , DENSE_RANK() over (partition by customer_id order by market_date) Customer_Visit_Counter 
  From  customer_purchases Cp;
 
/* 2. Reverse the numbering of the query from a part so each customer’s most recent visit is labeled 1, 
then write another query that uses this one as a subquery (or temp table) and filters the results to 
only the customer’s most recent visit. */

Select * 
 From(Select Cp.*
                         , row_number() over (partition by customer_id order by market_date desc) Customer_Recent_Visit_Date 
               From  customer_purchases Cp)A
 Where A.Customer_Recent_Visit_Date =1;

/* 3. Using a COUNT() window function, include a value along with each row of the 
customer_purchases table that indicates how many different times that customer has purchased that product_id. */

Select Cp.*
            ,Purchase_count
 From customer_purchases Cp
            Inner Join (Select customer_id
			                                    ,product_id
												,COUNT(1) Purchase_count
                                     From customer_purchases
                                    Group By customer_id,product_id)Pcnt 
					 on (Cp.customer_id =Pcnt.customer_id 
					         And Cp.product_id = Pcnt.product_id);

-- String manipulations
/* 1. Some product names in the product table have descriptions like "Jar" or "Organic". 
These are separated from the product name with a hyphen. 
Create a column using SUBSTR (and a couple of other commands) that captures these, but is otherwise NULL. 
Remove any trailing or leading whitespaces. Don't just use a case statement for each product! 

| product_name               | description |
|----------------------------|-------------|
| Habanero Peppers - Organic | Organic     |

Hint: you might need to use INSTR(product_name,'-') to find the hyphens. INSTR will help split the column. */

Select product_name
            ,Case When INSTR(product_name,'-') != 0 Then  TRIM(SUBSTR(product_name,INSTR(product_name,'-')+1, LENGTH(product_name)-INSTR(product_name,'-')))
                         Else  NULL End Description 
 From product;

/* 2. Filter the query to show any product_size value that contain a number with REGEXP. */

Select P.* 
  From product p
Where product_size REGEXP '"';

-- UNION
/* 1. Using a UNION, write a query that displays the market dates with the highest and lowest total sales.

HINT: There are a possibly a few ways to do this query, but if you're struggling, try the following: 
1) Create a CTE/Temp Table to find sales values grouped dates; 
2) Create another CTE/Temp table with a rank windowed function on the previous query to create 
"best day" and "worst day"; 
3) Query the second temp table twice, once for the best day, once for the worst day, 
with a UNION binding them. */

With sales AS(
                             Select market_date 
                                        , sum(quantity*cost_to_customer_per_qty) total_sales,row_number() over (order by sum(quantity*cost_to_customer_per_qty)  desc) sales_order 
                             From customer_purchases 
                            Group by market_date)

Select 'Max Sales Date' Sales_Status
             ,S.market_date
			 ,S.total_sales 
  From sales S 
 Where sales_order =1
UNION
Select 'Min Sales Date' Sales_Status
             ,S.market_date
			 ,S.total_sales  
  from sales S
 Where sales_order = (Select max(sales_order) 
                                              from sales);


/* SECTION 3 */

-- Cross Join
/*1. Suppose every vendor in the `vendor_inventory` table had 5 of each of their products to sell to **every** 
customer on record. How much money would each vendor make per product? 
Show this by vendor_name and product name, rather than using the IDs.

HINT: Be sure you select only relevant columns and rows. 
Remember, CROSS JOIN will explode your table rows, so CROSS JOIN should likely be a subquery. 
Think a bit about the row counts: how many distinct vendors, product names are there (x)?
How many customers are there (y). 
Before your final group by you should have the product of those two queries (x*y).  */
Select Max(V.vendor_name)  vendor_name
            ,Max(P.product_name)  product_name
			,sum(Total_Value) Total_Value
From(Select distinct vendor_id
                         ,product_id
		                 ,(original_price *5) Total_value   /*total value of 5 qty of the product*/
               From vendor_inventory )A
            Cross Join customer C
            Inner Join vendor V on (V.vendor_id=A.vendor_id)
            Inner Join product P on (P.product_id =A.product_id)
Group by A.vendor_id,A.product_id
Order by vendor_name,Total_Value;


-- INSERT
/*1.  Create a new table "product_units". 
This table will contain only products where the `product_qty_type = 'unit'`. 
It should use all of the columns from the product table, as well as a new column for the `CURRENT_TIMESTAMP`.  
Name the timestamp column `snapshot_timestamp`. */

Create table  product_units AS
Select *,  CURRENT_TIMESTAMP snapshot_timestamp
  From product
Where product_qty_type ='unit';


/*2. Using `INSERT`, add a new row to the product_units table (with an updated timestamp). 
This can be any product you desire (e.g. add another record for Apple Pie). */

Insert into product_units (product_id,product_name,product_size,product_category_id,product_qty_type,snapshot_timestamp)
Values (24,'Apple Cider - Jar','8 oz',2,'unit',CURRENT_TIMESTAMP);

Insert into product_units (product_id,product_name,product_size,product_category_id,product_qty_type,snapshot_timestamp)
Values (25,'Apple Pie','10"',3,'unit',CURRENT_TIMESTAMP);

-- DELETE
/* 1. Delete the older record for the whatever product you added. 

HINT: If you don't specify a WHERE clause, you are going to have a bad time.*/

Delete 
  From product_units
Where product_id in (Select product_id 
                                             From (Select product_id
											                          ,row_number() over (order by product_id desc) rno
                                                            From product_units 
                                                          Where product_name ='Apple Pie') A
                                           Where rno!=1);


-- UPDATE
/* 1.We want to add the current_quantity to the product_units table. 
First, add a new column, current_quantity to the table using the following syntax.

ALTER TABLE product_units
ADD current_quantity INT;

Then, using UPDATE, change the current_quantity equal to the last quantity value from the vendor_inventory details.

HINT: This one is pretty hard. 
First, determine how to get the "last" quantity per product. 
Second, coalesce null values to 0 (if you don't have null values, figure out how to rearrange your query so you do.) 
Third, SET current_quantity = (...your select statement...), remembering that WHERE can only accommodate one column. 
Finally, make sure you have a WHERE statement to update the right row, 
	you'll need to use product_units.product_id to refer to the correct row within the product_units table. 
When you have all of these components, you can run the update statement. */

ALTER TABLE product_units
ADD current_quantity INT;

Update product_units
Set current_quantity = IFNULL((Select quantity
                                               From(Select product_id
                                                                        ,quantity
                                                                        ,market_date
                                                                        ,row_number() over (Partition by product_id order by market_date desc)   rno
                                                              from vendor_inventory)Vi
                                              Where rno=1 And product_id = product_units.product_id),0);
   