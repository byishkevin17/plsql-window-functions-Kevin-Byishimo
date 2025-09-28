## 1. Problem Definition

- **Business Context:**
-Company :CityMart Retail Store
- Department: Sales management&Inventory
    - Industry: Retail grocery & Household Goods
- **Data Challenge**
    The store management Lacks analytical insights into sales performances across different regions and customer segments.without understanding which products are top performing in each region,how sales trends are evolving monthly, and which customers provide the most value, the store cannot optimize inventory planning or create effective targeted marketing campaigns. 
    
- **Expected Outcome**
    
    By using **PL/SQL window functions**, the company will uncover:
    
    - Top-selling products per region/district in Rwanda.
    - track monthly sales trends
    - Customer segmentation by spending
    - analyze growth rates

## 2. Success Criteria

- **Top 5 products per region/quarter** → Using `RANK()`

> This function helps to **rank products** based on sales within specific categories like region and quarter, identifying top performers.
> 
- **Running monthly sales totals** → Using `SUM() OVER()`

> This function is used to calculate **running totals of sales** month-over-month, showing cumulative progress throughout the year.
> 
- **Month-over-month growth percentage** → Using `LAG()`

> These functions facilitate the measurement of **month-over-month growth**, highlighting performance trends and the impact of business initiatives.
> **Segment customers into spending quartiles based on total purchase amount** Using NTILE(4)
> **Compute 3-month moving average of sales for better inventory forecasting** Using AVG() OVER()

![ER diagram](screenshots/01_transactions_table_has_relationship_to_all_table.png)
<!--   ![ message ](screenshots/)    -->


## 3.   Database Schema











