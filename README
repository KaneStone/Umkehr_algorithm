# Dobson Umkehr Documentation

## Version .9

### Kane Stone

University of Melbourne

currently at: Massachusetts Institute of Technology

stonek@mit.edu

---
## Contents


## Short description of Version .9
A description of the algorithm and analysis of the benefits in retrieval information have been described in [Stone et al., 2015](http://www.atmos-meas-tech.net/8/1043/2015/)


## Running the algorithm

1. [Measurement data format](#C1)

2. [Forward model data format](#C2)

3. [Algorithm flow chart](#C3)

---

### 1. Measurement data format <a name="C1"></a>

Test data from Melbourne is supplied in **ModelInputs.tar.gz**. This data needs to be in the directory, as seen from the Umkehr algorithm model directory: **../input/umkehr/Melbourne/1994/**

Any other umkehr input data to be used in the aglorithm needs to be in a similar directory structure: **../input/umkehr/[station]/[year]/**

Measurement data is required to adhere to the following NetCDF data standards to be used in the algorithm in the current form.

* Each measurement is contained in its own file with name: 

	[Station_name]_[yyyymmdd]_[Morning or Evening]_[WavelengthPairs]_Umkehr.nc
	
		Example: Melbourne_19940119_Evening_CPair_Umkehr.nc 
		Example: Brisbane_20120101_Morning_ACDPair_Umkehr.nc
		
* The NetCDF files have 2 dimensions: 

	1. **WaveLengthPair** 
	2. **MeasurementLength**

	and 6 variables

	1. **SolarZenithAngle**
	2. **SolarAzimuthAngle**
	3. **Nvalue**
	4. **Rvalue**
	5. **WaveLengthPair** (A decimal character representation)
	6. **Time** (A date number)

* If vector lengths of different wavelength pairs are not consistent, the differences are padded with the allocated missing values of -9999

* Latitude, Longitude, Instrument number, and UTC are contained in the global attributes.

Below is an example for the site of Melbourne.

		dimensions:
			WaveLengthPair = 1 ;
			MeasurementLength = 34 ;
		variables:
			double SolarZenithAngle(MeasurementLength, WLP) ;
				SolarZenithAngle:units = "SolarZenithAngle" ;
				SolarZenithAngle:units = "degrees" ;
				SolarZenithAngle:missing_value = -9999. ;
				SolarZenithAngle:valid_min = -1. ;
				SolarZenithAngle:valid_max = 1000. ;
			double SolarAzimuthAngle(MeasurementLength, WLP) ;
				SolarAzimuthAngle:units = "SolarAzimuthAngle" ;
				SolarAzimuthAngle:units = "degrees" ;
				SolarAzimuthAngle:missing_value = -9999. ;
				SolarAzimuthAngle:valid_min = -1. ;
				SolarAzimuthAngle:valid_max = 1000. ;
			double Nvalue(MeasurementLength, WLP) ;
				Nvalue:name = "Nvalue" ;
				Nvalue:units = "arbitrary" ;
				Nvalue:missing_value = -9999. ;
				Nvalue:valid_min = -1. ;
				Nvalue:valid_max = 1000. ;
			double Rvalue(MeasurementLength, WLP) ;
				Rvalue:name = "Rvalue" ;
				Rvalue:units = "arbitrary" ;
				Rvalue:missing_value = -9999. ;
				Rvalue:valid_min = -1. ;
				Rvalue:valid_max = 1000. ;
			double WaveLengthPair(WaveLengthPair) ;
				WLP:name = "WaveLengthPair" ;
				WLP:CPair_wavelengths = "311.4nm, 332.4nm" ;
				WLP:units = decimal ;
				WLP:valid_max = 1000. ;
			double Time(MeasurementLength, WLP) ;
				Time:name = "time" ;
				Time:units = "days since 00-Jan-0000" ;
				Time:missing_value = -9999. ;
				Time:valid_min = -1. ;

		// global attributes:
				:Latitude = "-38.02453" ;
				:Longitude = "145.10277" ;
				:Instrument_number = 12. ;
				:UTC = 10. ;

---

### 2. Forward model data format <a name="C2"></a>

All forward model data are provided as NetCDF files. These netcdf files are supplied in the release as **ModelInputs.tar.gz**. Once extracted, each profile input variable directory needs to be moved to the following directory path, as seen from the Umkehr algorithm path: **../inputs/forwardModelProfiles/[variable]**

* The NetCDF files have 3 dimensions with the exception of the aerosol file, which does not have a month component: 

	1. **Month**
	2. **Latitude (5 degree zonal average bins)**  
	3. **Height (km)**

	and 3 variables

	1. **Profile**
	2. **Month**
	3. **Latitude**
	4. **Height**

Forward model input data includes:

* **Ozone**

	Ozone is sourced from the Bodeker Scientific [vertically resolved ozone database](http://www.bodekerscientific.com/data/monthly-mean-global-vertically-resolved-ozone)

* **Temperature**

	Temperature is sourced from the Bodeker Scientific [BDBP](http://www.bodekerscientific.com/data/the-bdbp)

* **Pressure**

	Pressure is sourced from the Bodeker Scientific [BDBP](http://www.bodekerscientific.com/data/the-bdbp)

* **Aerosols** 

	Aerosols are currently sourced from SAGE II data [SAGE II]()
	

### 3. Algorithm function description <a name="C3"></a>

below is a short description of the algorithm as split into functions

[Maindriver](#F1)
	
* [userinputs](#S1)
* [namingconventions](#S2)
* [readUmkehr](#S3)
* [backupdata](#S4)
* [retrievalsetup](#S5)	
	* [profilereader](#S6)	
	* [definelambda](#S7)	
	* [xsectreader](#S8)	
	* [normalising_](#S8)	

#### Maindriver <a name="F1"></a>

* The top function of the algorithm.

#### userinputs <a name="S1"></a>

* All user inputs and switches are defined in this function. a description of each input option is also defined in the function.

#### namingconventions <a name="S2"></a> 

* This function checks the existence of output folders and created them if they don't exist. It also creates the names of the output files depending on the user input choices.

#### readUmkehr <a name="S3"></a> 

* Reads in Umkehr netcdf input data that is in the [measurement data format](#C1) within the date range specified in [userinputs](#S1). 

#### backupdata <a name="S4"></a> 

* Backs up previous output data as precaution due to known bug

#### retrievalsetup <a name="S5"></a> 

* sets up forward model parameters and calculated initial ray paths

	##### profilereader <a name="S6"></a> 
	
	* Reads in forward model profiles...
	
	##### definelambda <a name="S7"></a> 
	
	* Defines wavelength pair A, C, or D lambda values based on [userinputs](#S1) and what is available

	##### xsectreader <a name="S8"></a> 
	
	* Reads in ozone cross sections

