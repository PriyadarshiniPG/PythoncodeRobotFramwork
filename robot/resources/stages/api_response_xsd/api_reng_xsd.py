"""
This python file  contains XML and JSON xsd for all RENG API's
"""
import os

if os.environ["LAB_NAME"] == "labe2esuperset":
    collapseInstance = "collapseInstance"
    collapseSeries = "collapseSeries"
else:
    collapseInstance = "collapseInstance"
    collapseSeries = "collapseInstance"

JSON_SCHEMA = {

}

XML_SCHEMA = {
    "RENG_SEARCH_NODE":"""<xs:schema attributeFormDefault="unqualified" elementFormDefault="qualified" xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="recommendationsResult">
    <xs:complexType>
      <xs:sequence>
        <xs:element name="recommendations">
          <xs:complexType>
            <xs:sequence>
              <xs:element name="recommendation" maxOccurs="unbounded" minOccurs="0">
                <xs:complexType>
                  <xs:sequence>
                    <xs:element type="xs:byte" name="contentSourceId"/>
                    <xs:element type="xs:string" name="contentItemId"/>
                    <xs:element type="xs:string" name="contentLocationId"/>
                    <xs:element type="xs:string" name="contentItemPoster" minOccurs="0"/>
                    <xs:element type="xs:string" name="parentalRating"/>
                    <xs:element type="xs:string" name="contentGenre"/>
                    <xs:element type="xs:string" name="seriesId" minOccurs="0"/>
                    <xs:element name="%s" minOccurs="0"/>
                    <xs:element name="%s" minOccurs="0"/>
                  </xs:sequence>
                </xs:complexType>
              </xs:element>
            </xs:sequence>
          </xs:complexType>
        </xs:element>
      </xs:sequence>
    </xs:complexType>
  </xs:element>
</xs:schema>""" % (collapseSeries, collapseInstance),

    "RENG_SEARCH_NODE_VIP": """<xs:schema attributeFormDefault="unqualified" elementFormDefault="qualified" xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="recommendationsResult">
    <xs:complexType>
      <xs:sequence>
        <xs:element name="recommendations">
          <xs:complexType>
            <xs:sequence>
              <xs:element name="recommendation" maxOccurs="unbounded" minOccurs="0">
                <xs:complexType>
                  <xs:sequence>
                    <xs:element type="xs:byte" name="contentSourceId"/>
                    <xs:element type="xs:string" name="contentItemId"/>
                    <xs:element type="xs:string" name="contentLocationId"/>
                    <xs:element type="xs:string" name="contentItemPoster" minOccurs="0"/>
                    <xs:element type="xs:string" name="parentalRating"/>
                    <xs:element type="xs:string" name="contentGenre" minOccurs="0"/>
                    <xs:element type="xs:string" name="seriesId" minOccurs="0"/>
                    <xs:element type="xs:string" name="collapseSeries" minOccurs="0"/>
                    <xs:element type="xs:string" name="collapseInstance" minOccurs="0"/>
                  </xs:sequence>
                </xs:complexType>
              </xs:element>
            </xs:sequence>
          </xs:complexType>
        </xs:element>
      </xs:sequence>
    </xs:complexType>
  </xs:element>
</xs:schema>""",

    "RENG_SEARCH_INVALID_SUBSCRIBERID":"""<xs:schema attributeFormDefault="unqualified" elementFormDefault="qualified" xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="recommendationsResult">
    <xs:complexType>
      <xs:sequence>
        <xs:element name="errors">
          <xs:complexType>
            <xs:sequence>
              <xs:element type="xs:short" name="clientType"/>
              <xs:element name="contentSources">
                <xs:complexType>
                  <xs:sequence>
                    <xs:element type="xs:byte" name="contentSourceId" maxOccurs="unbounded" minOccurs="0"/>
                  </xs:sequence>
                </xs:complexType>
              </xs:element>
              <xs:element type="xs:string" name="error"/>
            </xs:sequence>
          </xs:complexType>
        </xs:element>
      </xs:sequence>
    </xs:complexType>
  </xs:element>
</xs:schema>"""


}