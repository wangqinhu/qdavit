#### qdavit: qPCR data analysis and visualization tool

---

The `qdavit` takes a table file containing CT values in CSV/TSV format and calculates the relative gene expression level via 2^-ddCT method. qdavit also produce a barplot showing the relative gene expression level with error bars, you can download a PDF image output via check 'Output PDF' option and click the download link.

Please ensure that the table is organized as follows:

- Each row represents a sample
- Each column represents a replicate
- Reference gene (left half) and test gene (right half) have the same number of replicates
- Sample name and replicate number are clearly labeled

CSV file example:
```
Sample,R1,R2,R3,T1,T2,T3
WT,18.32,18.64,18.45,23.99,23.65,23.71
KO,18.51,18.69,18.69,22.45,22.29,22.26
OE,18.58,18.55,18.57,23.44,23.62,23.45
M1,18.65,18.64,18.64,23.67,23.98,23.94
M2,18.57,18.67,18.69,21.99,22.02,22.19
M3,18.57,18.69,18.63,24.12,24.03,24.11
```

TSV file example:
```
Sample	R1	R2	R3	T1	T2	T3
WT	18.32	18.64	18.45	23.99	23.65	23.71
KO	18.51	18.69	18.69	22.45	22.29	22.26
OE	18.58	18.55	18.57	23.44	23.62	23.45
M1	18.65	18.64	18.64	23.67	23.98	23.94
M2	18.57	18.67	18.69	21.99	22.02	22.19
M3	18.57	18.69	18.63	24.12	24.03	24.11
```

`qdavit` is an open source shiny app, the source code is available at https://github.com/wangqinhu/qdavit
