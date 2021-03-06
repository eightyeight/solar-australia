{-# LANGUAGE OverloadedStrings #-}
module Data.SolarPower where

import Data.Aeson (FromJSON)
import Data.Aeson.Types
import Data.Geospatial hiding (properties)
import Data.LinearRing

data SolarArray = SolarArray [[Double]]
	deriving (Show)

data GHI = GHI [[Double]] Float
	deriving (Show)

data PropsGHI = PropsGHI { averageGHI :: Float }
	deriving (Show)

data DontCare = DontCare

readSolarArrays :: GeoFeatureCollection DontCare -> [SolarArray]
readSolarArrays geo = map SolarArray (coords geo)

readGHIs :: GeoFeatureCollection PropsGHI -> [GHI]
readGHIs geo = zipWith GHI (coords geo) (ghis geo)
ghis = map averageGHI . properties

properties = map _properties . _geofeatures
coords = (map fromLinearRing . map head . map _unGeoPolygon . map getPolygon . filter isPolygon . map _geometry . _geofeatures)
	where isPolygon (Polygon g) = True
	      isPolygon _ = False
	      getPolygon (Polygon g) = g

instance FromJSON DontCare where
	parseJSON _ = return DontCare

instance FromJSON PropsGHI where
	parseJSON (Object obj) = do
		ghi <- obj .: "avgGHI"
		return $ PropsGHI ghi
	parseJSON _ = return $ PropsGHI 0
