"""
This python file  contains XML and JSON xsd for all Traxis API's
"""

JSON_SCHEMA = {

}

XML_SCHEMA = {
    "GET_TRAXIS_VERSION" : """<xs:schema attributeFormDefault="unqualified" elementFormDefault="qualified" targetNamespace="urn:eventis:traxisweb:1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="Root">
    <xs:complexType>
      <xs:sequence>
        <xs:element type="xs:string" name="Name"/>
        <xs:element type="xs:string" name="Version"/>
        <xs:element type="xs:string" name="Description"/>
        <xs:element type="xs:float" name="InterfaceVersion"/>
      </xs:sequence>
      <xs:attribute type="xs:byte" name="id"/>
    </xs:complexType>
  </xs:element>
</xs:schema>""",

    "GET_PURCHASED_PRODUCT_FOR_INVALID_CPE" : """<xs:schema attributeFormDefault="unqualified" elementFormDefault="qualified" targetNamespace="urn:eventis:traxisweb:1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="Error">
    <xs:complexType>
      <xs:sequence>
        <xs:element type="xs:dateTime" name="Timestamp"/>
        <xs:element type="xs:string" name="Source"/>
        <xs:element type="xs:anyURI" name="OriginalUri"/>
        <xs:element type="xs:string" name="InternalError"/>
        <xs:element type="xs:string" name="Message"/>
      </xs:sequence>
    </xs:complexType>
  </xs:element>
</xs:schema>""",

    "GET_PURCHASED_PRODUCT_FOR_VALID_CPE":"""<xs:schema attributeFormDefault="unqualified" elementFormDefault="qualified" targetNamespace="urn:eventis:traxisweb:1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="Products">
    <xs:complexType>
      <xs:sequence>
        <xs:element name="Product" maxOccurs="unbounded" minOccurs="0">
          <xs:complexType>
            <xs:sequence>
              <xs:element type="xs:string" name="InShoppingCart"/>
              <xs:element type="xs:string" name="EntitlementState"/>
              <xs:element type="xs:dateTime" name="EntitlementStart"/>
              <xs:element type="xs:dateTime" name="EntitlementEnd"/>
              <xs:element type="xs:byte" name="NumberOfPurchases"/>
              <xs:element type="xs:string" name="OnWishList"/>
              <xs:element type="xs:string" name="CollectionItemResourceType"/>
              <xs:element type="xs:byte" name="CategoryCount"/>
              <xs:element type="xs:byte" name="ContentCount"/>
              <xs:element type="xs:byte" name="EventCount"/>
              <xs:element type="xs:byte" name="ExecutableCount"/>
              <xs:element type="xs:byte" name="ChannelCount"/>
              <xs:element type="xs:byte" name="ContentsTitleCount"/>
              <xs:element type="xs:byte" name="PreviewTitleCount"/>
              <xs:element type="xs:byte" name="SeriesCount"/>
              <xs:element name="LiveStreams" minOccurs="0">
                <xs:complexType>
                  <xs:sequence>
                    <xs:element name="LiveStream" maxOccurs="unbounded" minOccurs="0">
                      <xs:complexType>
                        <xs:simpleContent>
                          <xs:extension base="xs:string">
                            <xs:attribute type="xs:string" name="id" use="optional"/>
                          </xs:extension>
                        </xs:simpleContent>
                      </xs:complexType>
                    </xs:element>
                  </xs:sequence>
                  <xs:attribute type="xs:short" name="resultCount" use="optional"/>
                </xs:complexType>
              </xs:element>
              <xs:element type="xs:short" name="LiveStreamCount"/>
              <xs:element type="xs:string" name="IsAdult"/>
              <xs:element type="xs:string" name="IsAvailable"/>
              <xs:element type="xs:string" name="HasTstv"/>
              <xs:element type="xs:string" name="Type"/>
              <xs:element type="xs:string" name="Name"/>
              <xs:element type="xs:string" name="ShortSynopsis"/>
              <xs:element type="xs:string" name="Currency"/>
              <xs:element type="xs:dateTime" name="AvailabilityStart"/>
              <xs:element type="xs:dateTime" name="AvailabilityEnd"/>
              <xs:element type="xs:string" name="IsSuspended"/>
              <xs:element name="Pictures" minOccurs="0">
                <xs:complexType>
                  <xs:sequence>
                    <xs:element name="Picture">
                      <xs:complexType>
                        <xs:simpleContent>
                          <xs:extension base="xs:string">
                            <xs:attribute type="xs:string" name="type" use="optional"/>
                          </xs:extension>
                        </xs:simpleContent>
                      </xs:complexType>
                    </xs:element>
                  </xs:sequence>
                </xs:complexType>
              </xs:element>
              <xs:element name="Aliases">
                <xs:complexType>
                  <xs:sequence>
                    <xs:element name="Alias" maxOccurs="unbounded" minOccurs="0">
                      <xs:complexType>
                        <xs:simpleContent>
                          <xs:extension base="xs:string">
                            <xs:attribute type="xs:string" name="type" use="optional"/>
                            <xs:attribute type="xs:string" name="organization" use="optional"/>
                            <xs:attribute type="xs:string" name="authority" use="optional"/>
                            <xs:attribute type="xs:string" name="encoding" use="optional"/>
                          </xs:extension>
                        </xs:simpleContent>
                      </xs:complexType>
                    </xs:element>
                  </xs:sequence>
                </xs:complexType>
              </xs:element>
              <xs:element name="CustomProperties">
                <xs:complexType>
                  <xs:sequence>
                    <xs:element name="CustomProperty" maxOccurs="unbounded" minOccurs="0">
                      <xs:complexType>
                        <xs:simpleContent>
                          <xs:extension base="xs:string">
                            <xs:attribute type="xs:string" name="href" use="optional"/>
                          </xs:extension>
                        </xs:simpleContent>
                      </xs:complexType>
                    </xs:element>
                  </xs:sequence>
                </xs:complexType>
              </xs:element>
              <xs:element type="xs:float" name="ListPrice"/>
              <xs:element type="xs:string" name="IsAvailableForCpe"/>
              <xs:element type="xs:string" name="IsRentalPeriodIndefinite"/>
              <xs:element type="xs:string" name="IsDownloadAllowed"/>
              <xs:element type="xs:string" name="IsStreamingAllowed"/>
            </xs:sequence>
            <xs:attribute type="xs:string" name="id" use="optional"/>
          </xs:complexType>
        </xs:element>
      </xs:sequence>
      <xs:attribute type="xs:short" name="resultCount"/>
    </xs:complexType>
  </xs:element>
</xs:schema>""",

    "RETRIEVE_PRODUCTS":"""<xs:schema attributeFormDefault="unqualified" elementFormDefault="qualified" targetNamespace="urn:eventis:traxisweb:1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="Products">
    <xs:complexType>
      <xs:sequence>
        <xs:element name="Product" maxOccurs="unbounded" minOccurs="0">
          <xs:complexType>
            <xs:simpleContent>
              <xs:extension base="xs:string">
                <xs:attribute type="xs:string" name="id" use="optional"/>
              </xs:extension>
            </xs:simpleContent>
          </xs:complexType>
        </xs:element>
      </xs:sequence>
      <xs:attribute type="xs:short" name="resultCount"/>
    </xs:complexType>
  </xs:element>
</xs:schema>""",

    "GET_ALL_ASSETS":"""<xs:schema attributeFormDefault="unqualified" elementFormDefault="qualified" targetNamespace="urn:eventis:traxisweb:1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="Contents">
    <xs:complexType>
      <xs:sequence>
        <xs:element name="Content" maxOccurs="unbounded" minOccurs="0"/>
      </xs:sequence>
      <xs:attribute type="xs:int" name="resultCount"/>
	</xs:complexType>
  </xs:element>
</xs:schema>""",

  "FILTER_PRODUCTS":"""
  <xs:schema attributeFormDefault="unqualified" elementFormDefault="qualified" targetNamespace="urn:eventis:traxisweb:1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="Products">
    <xs:complexType>
      <xs:sequence>
        <xs:element name="Product" maxOccurs="unbounded" minOccurs="0">
          <xs:complexType>
            <xs:simpleContent>
              <xs:extension base="xs:string">
                <xs:attribute type="xs:string" name="id" use="optional"/>
              </xs:extension>
            </xs:simpleContent>
          </xs:complexType>
        </xs:element>
      </xs:sequence>
      <xs:attribute type="xs:short" name="resultCount"/>
    </xs:complexType>
  </xs:element>
</xs:schema>
  """,

    "RETRIEVE_ASSET_DETAILS" : """<xs:schema attributeFormDefault="unqualified" elementFormDefault="qualified" targetNamespace="urn:eventis:traxisweb:1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="Event">
    <xs:complexType>
      <xs:sequence>
        <xs:element name="Channels">
          <xs:complexType>
            <xs:sequence>
              <xs:element name="Channel">
                <xs:complexType>
                  <xs:simpleContent>
                    <xs:extension base="xs:string">
                      <xs:attribute type="xs:string" name="id"/>
                    </xs:extension>
                  </xs:simpleContent>
                </xs:complexType>
              </xs:element>
            </xs:sequence>
            <xs:attribute type="xs:byte" name="resultCount"/>
          </xs:complexType>
        </xs:element>
        <xs:element type="xs:byte" name="ChannelCount"/>
        <xs:element type="xs:byte" name="ProductCount"/>
        <xs:element name="Titles">
          <xs:complexType>
            <xs:sequence>
              <xs:element name="Title">
                <xs:complexType>
                  <xs:simpleContent>
                    <xs:extension base="xs:string">
                      <xs:attribute type="xs:string" name="id"/>
                    </xs:extension>
                  </xs:simpleContent>
                </xs:complexType>
              </xs:element>
            </xs:sequence>
            <xs:attribute type="xs:byte" name="resultCount"/>
          </xs:complexType>
        </xs:element>
        <xs:element type="xs:byte" name="TitleCount"/>
        <xs:element type="xs:byte" name="TstvContentCount"/>
        <xs:element type="xs:byte" name="TstvEventCount"/>
        <xs:element type="xs:string" name="TitleId"/>
        <xs:element type="xs:string" name="ChannelId"/>
        <xs:element type="xs:duration" name="Duration"/>
        <xs:element type="xs:short" name="DurationInSeconds"/>
        <xs:element type="xs:string" name="HasTstv"/>
        <xs:element type="xs:string" name="TSTVRecordingBlackout"/>
        <xs:element type="xs:short" name="HorizontalSize"/>
        <xs:element type="xs:short" name="VerticalSize"/>
        <xs:element type="xs:string" name="IsHD"/>
        <xs:element type="xs:string" name="Is3D"/>
        <xs:element type="xs:string" name="Resolution"/>
        <xs:element type="xs:string" name="DynamicRange"/>
        <xs:element type="xs:string" name="OriginalResolution"/>
        <xs:element type="xs:string" name="OriginalDynamicRange"/>
        <xs:element name="AudioMixType">
          <xs:complexType>
            <xs:simpleContent>
              <xs:extension base="xs:string">
                <xs:attribute type="xs:byte" name="type"/>
              </xs:extension>
            </xs:simpleContent>
          </xs:complexType>
        </xs:element>
        <xs:element name="OriginalLanguages">
          <xs:complexType>
            <xs:sequence>
              <xs:element type="xs:string" name="OriginalLanguage" maxOccurs="unbounded" minOccurs="0"/>
            </xs:sequence>
          </xs:complexType>
        </xs:element>
        <xs:element name="DubbedLanguages">
          <xs:complexType>
            <xs:sequence>
              <xs:element type="xs:string" name="DubbedLanguage" maxOccurs="unbounded" minOccurs="0"/>
            </xs:sequence>
          </xs:complexType>
        </xs:element>
        <xs:element name="CaptionLanguages">
          <xs:complexType>
            <xs:sequence>
              <xs:element type="xs:string" name="CaptionLanguage" maxOccurs="unbounded" minOccurs="0"/>
            </xs:sequence>
          </xs:complexType>
        </xs:element>
        <xs:element name="SignLanguages">
          <xs:complexType>
            <xs:sequence>
              <xs:element type="xs:string" name="SignLanguage"/>
            </xs:sequence>
          </xs:complexType>
        </xs:element>
        <xs:element name="SupplementalAudioDescriptions">
          <xs:complexType>
            <xs:sequence>
              <xs:element type="xs:string" name="SupplementalAudioDescription"/>
            </xs:sequence>
          </xs:complexType>
        </xs:element>
        <xs:element name="Aliases">
          <xs:complexType>
            <xs:sequence>
              <xs:element name="Alias">
                <xs:complexType>
                  <xs:simpleContent>
                    <xs:extension base="xs:string">
                      <xs:attribute type="xs:string" name="type"/>
                      <xs:attribute type="xs:string" name="organization"/>
                      <xs:attribute type="xs:string" name="authority"/>
                      <xs:attribute type="xs:string" name="encoding"/>
                    </xs:extension>
                  </xs:simpleContent>
                </xs:complexType>
              </xs:element>
            </xs:sequence>
          </xs:complexType>
        </xs:element>
        <xs:element name="CustomProperties">
          <xs:complexType>
            <xs:sequence>
              <xs:element name="CustomProperty" maxOccurs="unbounded" minOccurs="0">
                <xs:complexType>
                  <xs:simpleContent>
                    <xs:extension base="xs:dateTime">
                      <xs:attribute type="xs:string" name="href" use="optional"/>
                    </xs:extension>
                  </xs:simpleContent>
                </xs:complexType>
              </xs:element>
            </xs:sequence>
          </xs:complexType>
        </xs:element>
        <xs:element type="xs:dateTime" name="AvailabilityStart"/>
        <xs:element type="xs:dateTime" name="AvailabilityEnd"/>
        <xs:element type="xs:string" name="IsAvailable"/>
        <xs:element type="xs:dateTime" name="ActualStart"/>
        <xs:element type="xs:dateTime" name="ActualEnd"/>
        <xs:element type="xs:string" name="IsLive"/>
        <xs:element type="xs:string" name="NetworkRecordingLicense"/>
        <xs:element type="xs:string" name="NetworkRecordingBlackout"/>
      </xs:sequence>
      <xs:attribute type="xs:string" name="id"/>
    </xs:complexType>
  </xs:element>
</xs:schema>""",

    "RETRIEVE_ASSET_DETAILS_INVALID":"""<xs:schema attributeFormDefault="unqualified" elementFormDefault="qualified" targetNamespace="urn:eventis:traxisweb:1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="Error">
    <xs:complexType>
      <xs:sequence>
        <xs:element type="xs:dateTime" name="Timestamp"/>
        <xs:element type="xs:string" name="Source"/>
        <xs:element type="xs:anyURI" name="OriginalUri"/>
        <xs:element type="xs:string" name="InternalError"/>
        <xs:element type="xs:string" name="Message"/>
      </xs:sequence>
    </xs:complexType>
  </xs:element>
</xs:schema>""",

    "RETRIEVE_TSTVEVENTS_FOR_CHANNELID": """<xs:schema attributeFormDefault="unqualified" elementFormDefault="qualified" targetNamespace="urn:eventis:traxisweb:1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="Channel">
    <xs:complexType>
      <xs:sequence>
        <xs:element name="TstvEvents">
          <xs:complexType>
            <xs:sequence>
              <xs:element name="TstvEvent" maxOccurs="unbounded" minOccurs="0">
                <xs:complexType>
                  <xs:simpleContent>
                    <xs:extension base="xs:string">
                      <xs:attribute type="xs:string" name="id" use="optional"/>
                    </xs:extension>
                  </xs:simpleContent>
                </xs:complexType>
              </xs:element>
            </xs:sequence>
            <xs:attribute type="xs:short" name="resultCount"/>
          </xs:complexType>
        </xs:element>
      </xs:sequence>
      <xs:attribute name="id"/>
    </xs:complexType>
  </xs:element>
</xs:schema> """
}
