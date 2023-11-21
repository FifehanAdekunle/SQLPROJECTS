SELECT *
FROM Portfolioprojects..NashvilleHousing;

-- REMOVE TIMESTAMP FROM SALE DATE --
SELECT SaleDateconverted,CONVERT(Date,SaleDate) as SaleDateConv2
FROM Portfolioprojects..NashvilleHousing;

UPDATE NashvilleHousing
set SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
set SaleDateConverted = CONVERT(Date,SaleDate)


-- Filling null values in Property adress --
SELECT *
FROM Portfolioprojects..NashvilleHousing
where PropertyAddress is null;

SELECT *
FROM Portfolioprojects..NashvilleHousing
order by ParcelID


-- Populate Property Adress using Self join --
SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolioprojects..NashvilleHousing a
join Portfolioprojects..NashvilleHousing b
   on a.ParcelID = b.ParcelID
   And a.[UniqueID ] <>b.[UniqueID ]
where a.PropertyAddress is null

update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolioprojects..NashvilleHousing a
join Portfolioprojects..NashvilleHousing b
   on a.ParcelID = b.ParcelID
   And a.[UniqueID ] <>b.[UniqueID ]
where a.PropertyAddress is null

SELECT PropertyAddress,ParcelID
FROM Portfolioprojects..NashvilleHousing
order by ParcelID


-- Breaking Out Address Into Individual Cols (Address,City,State) --
SELECT PropertyAddress
FROM Portfolioprojects..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)  -1  ) as Address,
CHARINDEX(',',PropertyAddress )
FROM Portfolioprojects..NashvilleHousing



SELECT
PropertyAddress,
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)  -1 ) as Address,
SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress) +1 ,LEN(PropertyAddress)) as City
FROM Portfolioprojects..NashvilleHousing

-- Update Table--

ALTER TABLE NashvilleHousing
Add PropertySplitAdress  Nvarchar (255);

UPDATE NashvilleHousing
set PropertySplitAdress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)  -1  )


ALTER TABLE NashvilleHousing
Add PropertySplitCity  Nvarchar (255);

UPDATE NashvilleHousing
set  PropertySplitCity = SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress) +1 ,LEN(PropertyAddress))


Select*
FROM Portfolioprojects..NashvilleHousing

-- Spliting Owner Address using Parse Name --
Select OwnerAddress
FROM Portfolioprojects..NashvilleHousing

Select
PARSENAME (REPLACE (OwnerAddress,',','.'),3),
PARSENAME (REPLACE (OwnerAddress,',','.'),2),
PARSENAME (REPLACE (OwnerAddress,',','.'),1)
FROM Portfolioprojects..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAdress  Nvarchar (255);

UPDATE NashvilleHousing
set OwnerSplitAdress = PARSENAME (REPLACE (OwnerAddress,',','.'),3)


ALTER TABLE NashvilleHousing
Add PropertySplitCity  Nvarchar (255);

UPDATE NashvilleHousing
set  OwnerSplitCity  = PARSENAME (REPLACE (OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState  Nvarchar (255);

UPDATE NashvilleHousing
set  OwnerSplitState  = PARSENAME (REPLACE (OwnerAddress,',','.'),1)

Select*
FROM Portfolioprojects..NashvilleHousing


-- Change Y and N to yes and No in Sold as Vacant Field"

SELECT DISTINCT (SoldAsVacant),COUNT (SoldAsVacant)
FROM Portfolioprojects..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT  SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
      WHEN SoldAsVacant = 'N' THEN 'NO'
	  ELSE SoldAsVacant
	  END
FROM Portfolioprojects..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
      WHEN SoldAsVacant = 'N' THEN 'NO'
	  ELSE SoldAsVacant
	  END

Select*
FROM Portfolioprojects..NashvilleHousing



-- REMOVE DUPLICATE USING CTE--
WITH RowNumCTE AS(
Select*,
       ROW_NUMBER() OVER(
	   PARTITION BY ParcelID,
	                PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
					   UniqueID
					   )row_num
FROM Portfolioprojects..NashvilleHousing
--ORDER BY ParcelID
)
Select*
FROM RowNumCTE
Where row_num > 1
Order By PropertyAddress

WITH RowNumCTE AS(
Select*,
       ROW_NUMBER() OVER(
	   PARTITION BY ParcelID,
	                PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
					   UniqueID
					   )row_num
FROM Portfolioprojects..NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
Where row_num > 1
--Order By PropertyAddress


-- DELETE UNUSED COLUMNS --
SELECT *
FROM Portfolioprojects..NashvilleHousing


ALTER TABLE Portfolioprojects..NashvilleHousing
Drop COLUMN OwnerAddress, TaxDistrict,PropertyAddress,SaleDate