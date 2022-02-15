# Geocode routine
from censusgeocode import CensusGeocode

def return_geoid(address_input):
    if address_input is None:
        pass
    else:
        cg = CensusGeocode(benchmark='Public_AR_Current',
                           vintage='ACS2018_Current')
        server_responce = cg.onelineaddress(address_input,
                                            returntype='geographies')
        geoid = server_responce[0]['geographies']['Census Tracts'][0]['GEOID']
        return geoid

