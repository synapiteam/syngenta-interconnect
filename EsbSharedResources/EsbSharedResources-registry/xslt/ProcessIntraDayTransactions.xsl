<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:camt052="urn:iso:std:iso:20022:tech:xsd:camt.052.001.02" exclude-result-prefixes="camt052">
	<xsl:output method="xml" omit-xml-declaration="yes" encoding="UTF-8" indent="yes" />

	<xsl:param name="reportingDate" select="format-date(current-date(), '[Y0001][M01][D01]')"/>
	<xsl:param name="reportingTime" select="format-time(current-time(), '[H01][m01][s01]')"/>
	<xsl:param name="currentDateTime" select="concat($reportingDate, $reportingTime)"/>
	<xsl:param name="reportingDateFormatted" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
	<xsl:param name="reportingTimeFormatted" select="format-time(current-time(), '[H01]:[m01]:[s01]')"/>
	<xsl:param name="reportingDateTime" select="concat($reportingDateFormatted, 'T', $reportingTimeFormatted)"/>
	<xsl:param name="previousDay" select="current-date()-xs:dayTimeDuration('P1D')"/>
	<xsl:param name="previousDayDate" select="format-date($previousDay, '[Y0001]-[M01]-[D01]')"/>

	<xsl:variable name="lastTransactionTimestamp" select="''"/>
	<xsl:variable name="lastTransactionTimestampPrefix" select="''"/>
	<xsl:variable name="transactionDetails" select="''"/>
	<xsl:variable name="account" select="''"/>
	<xsl:variable name="amount" select="''"/>


	<xsl:template match="/">

		<xsl:variable name="lastTransactionTimestamp"
					  select="//IBGETACTRANSINTRADAYType/gIBGETACTRANSINTRADAYDetailType/mIBGETACTRANSINTRADAYDetailType[LASTTRANS=1]/TIMESTAMP"/>
		<xsl:variable name="account" select="//IBGETACTRANSINTRADAYType/gIBGETACTRANSINTRADAYDetailType/mIBGETACTRANSINTRADAYDetailType[1]/ACCOUNT"/>

		<camt052:Document>
			<BkToCstmrStmt>
				<GrpHdr>
					<MsgId><xsl:value-of select="concat('CAMT.052-',$account,'-',$currentDateTime)"/></MsgId>
					<CreDtTm><xsl:value-of select="concat($reportingDateTime,'+01:00')"/></CreDtTm>
				</GrpHdr>
				<Rpt>
					<Id><xsl:value-of select="concat('CAMT.052-',$account,'-',$currentDateTime)"/></Id>
					<CreDtTm><xsl:value-of select="concat($reportingDateTime,'+01:00')"/></CreDtTm>
					<FrToDt>
						<FrDtTm><xsl:value-of select="concat($reportingDateFormatted, 'T00:00:01+01:00')"/></FrDtTm>
						<ToDtTm>
							<xsl:choose>
								<xsl:when test="$lastTransactionTimestamp!=''">
									<xsl:call-template name="yyyy-mm-ddTHH-mm-ss-format">
										<xsl:with-param name="origDateString" select="$lastTransactionTimestamp" />
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''"/>
								</xsl:otherwise>
							</xsl:choose>
						</ToDtTm>
					</FrToDt>
					<Acct>
						<Id>
							<IBAN><xsl:value-of select="//IBGETACTRANSINTRADAYType/gIBGETACTRANSINTRADAYDetailType/mIBGETACTRANSINTRADAYDetailType[1]/IBAN" /></IBAN>
						</Id>
						<Ccy><xsl:value-of select="//IBGETACTRANSINTRADAYType/gIBGETACTRANSINTRADAYDetailType/mIBGETACTRANSINTRADAYDetailType[1]/CURRENCY"/></Ccy>
					</Acct>
					<xsl:apply-templates select="//IBGETACTRANSINTRADAYType/gIBGETACTRANSINTRADAYDetailType/mIBGETACTRANSINTRADAYDetailType" />
				</Rpt>
			</BkToCstmrStmt>
		</camt052:Document>
	</xsl:template>

	<xsl:template match="mIBGETACTRANSINTRADAYDetailType">
	 <xsl:variable name="amount" select="number(replace(AMOUNT[text()], '&#x9;', ''))" />
		<Ntry>
			<Amt>
				<xsl:attribute name="Ccy">
					<xsl:value-of select="CURRENCY" />
				</xsl:attribute>
				<xsl:choose>
					<xsl:when test="$amount &lt; 0">
						<xsl:value-of select="-1*$amount" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$amount" />
					</xsl:otherwise>
				</xsl:choose>
			</Amt>

			<CdtDbtInd>
				<xsl:choose>
					<xsl:when test="$amount &gt;= 0">CRDT</xsl:when>
					<xsl:otherwise>DBIT</xsl:otherwise>
				</xsl:choose>
			</CdtDbtInd>
			<Sts>BOOK</Sts>
			<BookgDt>
				<Dt>
					<xsl:choose>
						<xsl:when test="BOOKINGDATE!=''">
							<xsl:call-template name="yyyymmddToyyyy-mm-dd-format">
								<xsl:with-param name="origDateString" select="BOOKINGDATE" />
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise><xsl:value-of select="''" /></xsl:otherwise>
					</xsl:choose>
				</Dt>
			</BookgDt>
			<ValDt>
				<Dt>
					<xsl:choose>
						<xsl:when test="VALUEDATE!=''">
							<xsl:call-template name="yyyymmddToyyyy-mm-dd-format">
								<xsl:with-param name="origDateString" select="VALUEDATE" />
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise><xsl:value-of select="''" /></xsl:otherwise>
					</xsl:choose>
				</Dt>
			</ValDt>
			<AcctSvcrRef><xsl:value-of select="TRANSACTIONREFERENCE"/></AcctSvcrRef>
			<BkTxCd>
				<Prtry>
					<Cd>
						<xsl:choose>
							<xsl:when test="TRANSACTIONCODE=210 or TRANSACTIONCODE=212 or TRANSACTIONCODE=220 or TRANSACTIONCODE=222">
								<xsl:value-of select="'NTRF'" />
							</xsl:when>
							<xsl:when test="TRANSACTIONCODE=230 or TRANSACTIONCODE=232">
								<xsl:value-of select="'NCOM'" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="'NMSC'" />
							</xsl:otherwise>
						</xsl:choose>
					</Cd>
					<Issr>SWIFT</Issr>
				</Prtry>
			</BkTxCd>
			<NtryDtls>
				<TxDtls>
					<RmtInf>
						<Ustrd><xsl:value-of select="TRANSACTIONDESCRIPTION" /></Ustrd>
						<xsl:if test="TRANSDET1!=''">
								<Ustrd><xsl:value-of select="TRANSDET1"/></Ustrd>
                        </xsl:if>
                        <xsl:if test="TRANSDET2!=''">
								<Ustrd><xsl:value-of select="TRANSDET2"/></Ustrd>
                        </xsl:if>
                        <xsl:if test="TRANSDET3!=''">
								<Ustrd><xsl:value-of select="TRANSDET3"/></Ustrd>
                        </xsl:if>
                        <xsl:if test="TRANSDET4!=''">
								<Ustrd><xsl:value-of select="TRANSDET4"/></Ustrd>
                        </xsl:if>
                        <xsl:if test="TRANSDET5!=''">
								<Ustrd><xsl:value-of select="TRANSDET5"/></Ustrd>
                        </xsl:if>
					</RmtInf>
				</TxDtls>
			</NtryDtls>
		</Ntry>
	</xsl:template>

	<xsl:template name="yyyymmddToyyyy-mm-dd-format">
		<xsl:param name="origDateString" />

		<xsl:variable name="yr" select="substring($origDateString,1,4)" />
		<xsl:variable name="mo" select="concat('-',substring($origDateString,5,2))" />
		<xsl:variable name="dy" select="concat('-',substring($origDateString,7,2))" />

		<xsl:value-of select="concat($yr,concat($mo,$dy))" />

	</xsl:template>

	<xsl:template name="yyyy-mm-ddTHH-mm-ss-format">
		<xsl:param name="origDateString" />

		<xsl:variable name="year" select="substring($origDateString,1,4)" />
		<xsl:variable name="month" select="concat('-',substring($origDateString,5,2))" />
		<xsl:variable name="day" select="concat('-',substring($origDateString,7,2))" />
		<xsl:variable name="prefix" select="concat($year,concat($month,$day))" />

		<xsl:variable name="hour" select="substring($origDateString,9,2)" />
		<xsl:variable name="minutes" select="substring($origDateString,11,2)" />
		<xsl:variable name="sufix" select="concat($hour,'-',$minutes)" />

		<xsl:value-of select="concat($prefix,'T',$sufix,':00+01:00')"/>
	</xsl:template>

</xsl:stylesheet>