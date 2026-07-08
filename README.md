FDA Drug Recall Analysis

Analysis of the FDA drug enforcement recall database to identify the primary causes of pharmaceutical recalls and evaluate the efficiency of both industry and regulatory bodies in initiating and managing recall processes.


Dataset

Data sourced from the FDA OpenFDA Drug Enforcement API:


Source: https://open.fda.gov/apis/drug/enforcement/
Extraction method: REST API with pagination (17,711 records)
Coverage: 2006–2026
Key fields: recall classification, reason for recall, recalling firm, recall initiation date, center classification date



Project Structure

fda-drug-recall-analysis/

│

├── data/

│   ├── 01_fda_data_raw.csv          # Raw data extracted from OpenFDA API

│   └── 02_fda_data_clean.csv        # Cleaned dataset ready for analysis

│

├── notebooks/

│   ├── 01_data_collection.ipynb     # API extraction and raw data export

│   ├── 02_data_cleaning.ipynb       # Data cleaning and feature engineering

│   └── 03_eda.ipynb                 # Exploratory Data Analysis (4 KPIs)

│

├── fda_recall_sql/

│   ├── 02_fda_data_clean.csv        # Cleaned dataset ready for analysis

│   ├── fda_drug_recall.sql         # Exploratory Data Analysis in PostgreSQL (4 KPIs)

└── README.md


Key Findings


Sterility (35.4%) and Contamination (16.3%) are the leading causes of drug recalls, both associated with Class I and Class II severity — the highest risk categories for patient safety.
80.8% of recalls are Class II and 99.8% are firm-initiated, suggesting that post-commercialization pharmacovigilance mechanisms are functioning within the industry, with possible informal FDA pressure preceding official mandates.
Following the introduction of FDASIA (July 2012), a long-term decreasing trend of -91.8 recalls/year is observed, suggesting progressive improvement in pharmaceutical manufacturing quality.
The 2018 Class I spike is attributable to the ARB contamination crisis (valsartan, losartan, irbesartan), where multiple manufacturers recalled products contaminated with NDMA, a potential carcinogen found in the API synthesis process.



Tech Stack

ToolUsagePython 3.xCore languagepandasData manipulation and cleaningmatplotlibData visualizationseabornStatistical visualizationsnumpyNumerical computationrequestsOpenFDA API calls


How to Run


Clone the repository:


bashgit clone https://github.com/nicolavanzani-sys/fda-drug-recall-analysis.git
cd fda-drug-recall-analysis


Install dependencies:


bashpip install -r requirements.txt


Run the notebooks in order:

01_data_collection.ipynb — extracts raw data from OpenFDA API and exports to data/
02_data_cleaning.ipynb — cleans the raw dataset and exports the clean version to data/
03_eda.ipynb — runs the full exploratory analysis across 4 KPIs


Methodological Notes


Recall categorization uses a single-hierarchy keyword approach on reason_for_recall. Records with multiple causes are assigned to the highest-severity category. Storage is known to be underrepresented (~48 classified vs 584 containing "temperature").
Firm classification (compounding vs manufacturer) is keyword-based and may misclassify firms with non-descriptive names (e.g. Pharmedium Services LLC).
Three firms excluded from Top Recalling Firms analysis (King Bio Inc., Attix Pharmaceuticals, Aidapak Services LLC) due to recall volumes dominated by single mass-recall events rather than recurring manufacturing issues.
Records with classification time > 365 days excluded from KPI 2 analysis (1.4% of dataset).


SQL Analysis

Four analytical queries written in PostgreSQL are available in the `fda_recall_sql/` folder.
The queries replicate and extend the Python EDA analysis, demonstrating consistency 
between the two approaches.

| Query | Business Question | Key Technique |
|---|---|---|
| Top 10 firms by Class I recalls | Which firms have the highest number of the most severe recalls? | CTE, GROUP BY, percentage calculation |
|---|---|---|
| Avg classification time by severity | How long does the FDA take to classify a recall by severity class? | CTE, AVG, date arithmetic |
|---|---|---|
| Voluntary vs mandated by year | How has the ratio of firm-initiated vs FDA-mandated recalls evolved since FDASIA? | CTE, CASE WHEN, window function SUM() OVER |
|---|---|---|
| Recall category ranking by response time | Which recall categories require the longest FDA classification time? | CTE, CASE WHEN, RANK() OVER |

**Setup:** Import `data/02_fda_data_clean.csv` into a PostgreSQL database 
and run the queries in `fda_recall_sql/fda_drug_recall.sql`.



Author

Nicola Vanzani


GitHub: nicolavanzani-sys
Background: Chemistry, Biotechnology, Pharmaceutical QC & Manufacturing
