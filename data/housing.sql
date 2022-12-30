use housing;
/* data cleaning 

/* Standarise Format */


/* Property Address */

SELECT 
    *
FROM
    nashville
WHERE
    PropertyAddress = ''
ORDER BY ParcelID;

UPDATE nashville 
SET 
    PropertyAddress = NULLIF(PropertyAddress, '');

SELECT 
    a.PropertyAddress,
    a.ParcelID,
    b.PropertyAddress,
    b.ParcelID,
    IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM
    nashville a
        JOIN
    nashville b ON a.ParcelID = b.ParcelID
        AND a.UniqueID <> b.UniqueID
WHERE
    a.PropertyAddress IS NULL;

UPDATE nashville a
        JOIN
    nashville b ON a.ParcelID = b.ParcelID
        AND a.UniqueID <> b.UniqueID 
SET 
    a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE
    a.PropertyAddress IS NULL;

SELECT 
    *
FROM
    nashville
WHERE
    PropertyAddress IS NULL
ORDER BY ParcelID;  /* no value shows w hat means we done inner join correctly */

/* Breaking property addres into individual columns */

SELECT 
    PropertyAddress
FROM
    nashville;

SELECT 
    SUBSTRING_INDEX(PropertyAddress, ',', 1) AS Address,
    SUBSTRING_INDEX(PropertyAddress, ',', - 1) AS City
FROM
    nashville;

ALTER TABLE nashville
ADD COLUMN PropertyAddressSplit VARCHAR(100);

UPDATE nashville 
SET 
    PropertyAddressSplit = SUBSTRING_INDEX(PropertyAddress, ',', - 1);

ALTER TABLE nashille
ADD COLUMN PropertyCitySplit VARCHAR(45);

UPDATE nashville 
SET 
    PropertyCitySplit = SUBSTRING_INDEX(PropertyAddress, ',', - 1);

/* Breaking owner addres into individual columns */

SELECT 
    SUBSTRING_INDEX(OwnerAddress, ',', - 1) AS OwnerStateSplit,
    SUBSTRING_INDEX(OwnerAddress, ',', 1) AS OwnerAddressSplit,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),
            ',',
            - 1) AS OwnerCitySplit
FROM
    nashville;

ALTER TABLE nashville
ADD COLUMN OwnerAddressSplit VARCHAR(100);

UPDATE nashville 
SET 
    OwnerAddressSplit = SUBSTRING_INDEX(OwnerAddress, ',', 1);

ALTER TABLE nashville
ADD COLUMN OwnerCitySplit VARCHAR(100);

UPDATE nashville 
SET 
    OwnerCitySplit = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),
            ',',
            - 1);

ALTER TABLE nashville
ADD COLUMN OwnerStateSplit VARCHAR(100);

UPDATE nashville 
SET 
    OwnerStateSplit = SUBSTRING_INDEX(OwnerAddress, ',', - 1);

/* Change Y to Yes and N to No in "Sold as Vacant*/

SELECT DISTINCT
    (SoldAsVacant), COUNT(SoldAsVacant)
FROM
    nashville
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT 
    SoldAsVacant,
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END
FROM
    nashville;

Update nashville set  SoldAsVacant=
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END;
    
/* Remove duplicate */

WITH RowNumCTE AS(
SELECT *, 
	row_number() OVER(
	PARTITION BY ParcelID, 
		PropertyAddress, 
		SalePrice, 
		SaleDate, 
		LegalReference
		ORDER BY 
			UniqueID
            ) row_num
            
FROM nashville
ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num>1;

/* Delete useless column */

Alter table nashville
drop column TaxDistrict;

/* finnal table */

SELECT * FROM nashville;
