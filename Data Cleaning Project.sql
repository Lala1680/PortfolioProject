
Select *
From PortfolioProject..[NashvilleHousing ]


---------------------------------------------------------------------------------------------------------------

-- Standarised Date Format



Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject..[NashvilleHousing ]

Update [NashvilleHousing ]
SET SaleDate = CONVERT(Date, SaleDate)


Alter Table [NashvilleHousing ]
Add SaleDateConverted Date;

Update [NashvilleHousing ]
SET SaleDateConverted = CONVERT(Date, SaleDate)


-------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data


Select *
From PortfolioProject..[NashvilleHousing ]
--where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)	
From PortfolioProject..[NashvilleHousing ] a
JOIN PortfolioProject..[NashvilleHousing ] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)	
From PortfolioProject..[NashvilleHousing ] a
JOIN PortfolioProject..[NashvilleHousing ] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


----------------------------------------------------------------------------------------------------------------------

-- Breaking address into Individual Column (Address, City , State)


Select PropertyAddress
From PortfolioProject..[NashvilleHousing ]

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress)) as Address
From PortfolioProject..[NashvilleHousing ]

Alter Table [NashvilleHousing ]
Add PropertySplitAddress Nvarchar(255);

Update [NashvilleHousing ]
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table [NashvilleHousing ]
Add PropertySplitCity Nvarchar(255);

Update [NashvilleHousing ]
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress))


Select *
From PortfolioProject..[NashvilleHousing ]




Select OwnerAddress
From PortfolioProject..[NashvilleHousing ]


Select 
PARSENAME(replace(OwnerAddress, ',', '.'), 3)
, PARSENAME(replace(OwnerAddress, ',', '.'), 2)
, PARSENAME(replace(OwnerAddress, ',', '.'), 1)
From PortfolioProject..[NashvilleHousing ]



Alter Table [NashvilleHousing ]
Add OwnerSplitAddress Nvarchar(255);

Update [NashvilleHousing ]
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

Alter Table [NashvilleHousing ]
Add OwnerSplitCity Nvarchar(255);

Update [NashvilleHousing ]
SET OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

Alter Table [NashvilleHousing ]
Add OwnerSplitState Nvarchar(255);

Update [NashvilleHousing ]
SET OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)


Select *
From PortfolioProject..[NashvilleHousing ]



-----------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Solid as vacant" field 


Select distinct(SoldAsVacant), count(SoldAsVacant)
From PortfolioProject..[NashvilleHousing ]
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' then 'Yes'
	   When SoldAsVacant = 'N' then 'No'
	   ELSE SoldAsVacant
	   End
From PortfolioProject..[NashvilleHousing ]


Update [NashvilleHousing ]
SET SoldAsVacant =  CASE When SoldAsVacant = 'Y' then 'Yes'
	   When SoldAsVacant = 'N' then 'No'
	   ELSE SoldAsVacant
	   End



-------------------------------------------------------------------------------------------------------------------

-- Remove duplicates

Select *
From PortfolioProject..[NashvilleHousing ]

WITH RowNumCTE as (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	Order by
					UniqueID
				 ) row_num
From PortfolioProject..[NashvilleHousing ]
--Order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress




-------------------------------------------------------------------------------------------------------------------

-- Delete unused columns


Select *
From PortfolioProject..[NashvilleHousing ]

Alter table PortfolioProject..[NashvilleHousing ]
Drop column OwnerAddress, TaxDistrict, PropertyAddress


Alter table PortfolioProject..[NashvilleHousing ]
Drop column SaleDate