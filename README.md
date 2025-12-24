# NASA Federal Spending Analysis Engine (FY 2024)

### About the Project
In this study, I examined NASA's federal expenditures between October 2023 and September 2024 (Federal Fiscal Year 2024) through an end-to-end data engineering and analysis process. The primary objective of the project is to reveal how vast amounts of public resources are distributed, which companies play a strategic role in this process, and the financial dynamics within spending patterns.

---

### 4 Core Questions Answered Within the Scope of the Analysis
During the analysis process, I sought answers to the following critical questions regarding NASA's budget management:

1.  **Market Concentration Analysis (Market Share):** How much of NASA's budget goes to large-scale companies? Is there an oligopoly structure or concentration risk in the supply chain?
2.  **Spending Trends and Burn Rate (Moving Average):** When we clean the seasonal noise in monthly expenditures, in which direction is NASA's real spending trend evolving?
3.  **Quarterly Funding Momentum (QoQ Growth):** How did companies start and end the fiscal year? What are the performance differences between the first quarter (Q1) and the last quarter (Q4)?
4.  **Fiscal Year-End "September Surge":** Is there a statistically significant increase in expenditures during the last month of the fiscal year due to public budget discipline?

---

### Analysis Results and Findings
The financial interpretations derived from the outputs I obtained are as follows:

* **Market Concentration and Dependency Risk:** According to the analysis results, **11.10%** of NASA's budget was transferred solely to the **California Institute of Technology**, and **9.95%** to **SpaceX**. The fact that the top 5 companies control approximately **39.44%** of the total budget proves that the institution is highly dependent on specific recipients for strategic projects and that an oligopoly structure dominates the market.
* **Spending Trends and Moving Average:** When monthly expenditures are examined, it is observed that the data presents a highly volatile structure. The peaks in April 2024 at **$2.43 billion** and September 2024 at **$2.71 billion** are particularly noteworthy. The 3-month moving average (`three_month_ma`) shows that the spending rate steadily rose in the last quarter of the year, gaining momentum toward the fiscal year-end.
* **Quarterly Performance and Company Growth:** Comparing the beginning (Q1) and the end (Q4) of the fiscal year, astronomical increases in the amount of funding for certain companies were observed. For instance, firms such as **Ares Technical Services** and **ASRC Federal** increased their funding amounts thousands of times toward the end of the year, taking the lion's share of the budget distribution at the fiscal year-end.
* **Monthly Growth (MoM) and September Surge:** When monthly growth rates are analyzed, the jumps of **86.32%** in April and **66.95%** in July indicate that expenditures are clustered according to periodic projects. The **19.34%** increase in expenditures in September, the last month of the fiscal year, is a statistical indicator of the budget-burning operation known in the literature as the **"September Surge."**

---

### Methodology and Technical Process
I carried out the project with a professional Data Warehouse architecture by following these steps:

* **Data Acquisition and Cleaning:** I integrated NASA spending data into the system in raw format using Python. I optimized the financial values and date columns in the dataset for analysis.
* **Architectural Design (Star Schema):** To ensure relational data integrity, I modeled the data in a **Star Schema** structure. In this context, I created the dimension tables `dim_recipient` (Recipients), `dim_award` (Awards/Contracts), and the `fact_spending` (Expenditures) table, which aggregates all transactions at the center.
* **SQL Integration and Optimization:** I transferred the prepared data to the PostgreSQL database. To obtain results in milliseconds even across millions of rows, I developed **Index** strategies and optimized query plans using `EXPLAIN ANALYZE`.
* **Analytical Querying and Visualization:** I utilized advanced SQL techniques (Window Functions, CTEs, Pivot) to answer the 4 core questions I identified. I transferred these refined data points from the SQL environment to the Python environment and transformed them into interactive and dynamic graphics using the **Plotly** library.

---

### Project Purpose and Achievements
With this project, I primarily aimed to take my **SQL skills** to an advanced level and gain the competence to use Python and SQL in an integrated manner. Beyond just storing data, I developed my **Data Storytelling** skills by extracting strategic stories from data through an interactive visualization process via **Plotly**.
