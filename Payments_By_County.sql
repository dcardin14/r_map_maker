SELECT

CAST(CAS_Contract_County.CoCo_County_Code AS INT) AS 'CountyCode',
SUM(CAS_Payment.Amount_Paid) AS 'AMT_PAID'

FROM CAS_Contract_County INNER JOIN CAS_Contract ON CAS_Contract.ContractID = CAS_Contract_County.CoCo_ContractID
INNER JOIN CAS_Payment ON CAS_Payment.Payment_ContractID = CAS_Contract.ContractID

WHERE CAS_Contract_County.CoCo_County_Code < '255'

GROUP BY CAS_Contract_County.CoCo_County_Code

ORDER BY CAS_Contract_County.CoCo_County_Code
