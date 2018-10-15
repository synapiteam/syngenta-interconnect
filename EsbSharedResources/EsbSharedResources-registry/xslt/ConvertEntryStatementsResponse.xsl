<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:camt053="urn:iso:std:iso:20022:tech:xsd:camt.053.001.03" exclude-result-prefixes="camt053">

	<xsl:output method="xml" omit-xml-declaration="yes" encoding="UTF-8" indent="yes" />

	<xsl:param name="reportingDate" select="format-date(current-date(), '[Y0001][D01][M01]')" />
	<xsl:param name="reportingDateFormatted" select="format-date(current-date(), '[Y0001]-[D01]-[M01]')" />
	<xsl:param name="reportingTime" select="format-time(current-time(), '[H01]:[m01]:[s01]')" />
	<xsl:param name="reportingDateTime" select="concat($reportingDateFormatted, 'T', $reportingTime)" />
	<xsl:param name="previousDay" select="current-date()-xs:dayTimeDuration('P1D')" />
	<xsl:param name="previousDayDate" select="format-date($previousDay, '[Y0001]-[D01]-[M01]')" />

	<xsl:variable name="amountBalanceBefore" select="''" />
	<xsl:variable name="lastTransactionTimestamp" select="''" />
	<xsl:variable name="lastTransactionTimestampPrefix"
		select="''" />


	<xsl:template match="/">

		<xsl:variable name="amountBalanceBefore" select="//IBGETACTRANSTODAYType/gIBGETACTRANSTODAYDetailType/mIBGETACTRANSTODAYDetailType[FIRSTTRANS=1]/BALANCEBEFORE" />
		<xsl:variable name="amountBalanceAfter" select="//IBGETACTRANSTODAYType/gIBGETACTRANSTODAYDetailType/mIBGETACTRANSTODAYDetailType[LASTTRANS=1]/BALANCEAFTER" />
		<xsl:variable name="lastTransactionTimestamp" select="//IBGETACTRANSTODAYType/gIBGETACTRANSTODAYDetailType/mIBGETACTRANSTODAYDetailType[LASTTRANS=1]/TIMESTAMP" />

		<xsl:variable name="lastTransactionTimestampPrefix" select="concat(substring($lastTransactionTimestamp, 1, 4),'-',substring($lastTransactionTimestamp, 5, 2),'-',substring($lastTransactionTimestamp, 7, 2))" />

		<camt053:Document>

			<BkToCstmrStmt>
				<GrpHdr>
					<MsgId>
						<xsl:value-of select="concat('CAMT.053-', $reportingDate)" />
					</MsgId>
					<CreDtTm>
						<xsl:value-of select="$reportingDateTime" />
					</CreDtTm>
				</GrpHdr>
				<Stmt>
					<Id>
						<xsl:value-of select="//ACCOUNT" />
					</Id>
					<ElctrncSeqNb>
						<xsl:value-of select="$reportingDate" />
					</ElctrncSeqNb>
					<CreDtTm>
						<xsl:value-of select="$reportingDateTime" />
					</CreDtTm>
					<FrToDt>
						<FrDtTm>
							<xsl:value-of
								select="concat($reportingDateFormatted, 'T00:00:00+01:00')" />
						</FrDtTm>
						<ToDtTm>
							<xsl:choose>
								<xsl:when test="$lastTransactionTimestampPrefix!=''">
									<xsl:value-of
										select="concat($lastTransactionTimestampPrefix,'T',substring($lastTransactionTimestamp,10,5),':00+01:00')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</ToDtTm>
					</FrToDt>
					<Acct>
						<Id>
							<IBAN>
								<xsl:value-of select="//IBAN" />
							</IBAN>
						</Id>
						<Ccy>
							<xsl:value-of select="//CURRENCY" />
						</Ccy>
					</Acct>
					<Bal>
						<Tp>
							<CdOrPrtry>
								<Cd>PRCD</Cd>
							</CdOrPrtry>
						</Tp>
						<Amt>
							<xsl:attribute name="Ccy">
												<xsl:value-of select="//CURRENCY" />
											 </xsl:attribute>
							<xsl:choose>
								<xsl:when test="$amountBalanceBefore &lt; 0">
									<xsl:value-of select="-1 * $amountBalanceBefore" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$amountBalanceBefore" />
								</xsl:otherwise>
							</xsl:choose>
						</Amt>
						<CdtDbtInd>
							<xsl:choose>
								<xsl:when test="$amountBalanceBefore &gt;=  0">
									CRDT
								</xsl:when>
								<xsl:otherwise>
									DBIT
								</xsl:otherwise>
							</xsl:choose>
						</CdtDbtInd>
						<Dt>
							<Dt>
								<xsl:value-of select="$previousDayDate" />
							</Dt>
						</Dt>
					</Bal>
					<Bal>
						<Tp>
							<CdOrPrtry>
								<Cd>CLBD</Cd>
							</CdOrPrtry>
						</Tp>
						<Amt>
							<xsl:attribute name="Ccy">
												<xsl:value-of select="//CURRENCY" />
											 </xsl:attribute>
							<xsl:choose>
								<xsl:when test="$amountBalanceAfter &lt; 0">
									<xsl:value-of select="-1 * $amountBalanceAfter" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$amountBalanceAfter" />
								</xsl:otherwise>
							</xsl:choose>
						</Amt>
						<CdtDbtInd>
							<xsl:choose>
								<xsl:when test="$amountBalanceAfter &gt;=  0">
									CRDT
								</xsl:when>
								<xsl:otherwise>
									DBIT
								</xsl:otherwise>
							</xsl:choose>
						</CdtDbtInd>
						<Dt>
							<Dt>
								<xsl:value-of select="substring-before($reportingDateTime,'T')" />
							</Dt>
						</Dt>
					</Bal>
					<xsl:apply-templates
						select="//IBGETACTRANSTODAYType/gIBGETACTRANSTODAYDetailType/mIBGETACTRANSTODAYDetailType" />
				</Stmt>
			</BkToCstmrStmt>
		</camt053:Document>
	</xsl:template>

	<xsl:template match="mIBGETACTRANSTODAYDetailType">
		<Ntry>
			<Amt>
				<xsl:attribute name="Ccy">
						<xsl:value-of select="CURRENCY" />
				    </xsl:attribute>
				<xsl:choose>
					<xsl:when test="AMOUNT &lt; 0">
						<xsl:value-of select="-1 * AMOUNT" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="AMOUNT" />
					</xsl:otherwise>
				</xsl:choose>
			</Amt>

			<CdtDbtInd>
				<xsl:choose>
					<xsl:when test="AMOUNT &gt;= 0">
						CRDT
					</xsl:when>
					<xsl:otherwise>
						DBIT
					</xsl:otherwise>
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
						<xsl:otherwise>
							<xsl:value-of select="''" />
						</xsl:otherwise>
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
						<xsl:otherwise>
							<xsl:value-of select="''" />
						</xsl:otherwise>
					</xsl:choose>
				</Dt>
			</ValDt>
			<AcctSvcrRef>
				<xsl:value-of select="TRANSACTIONREFERENCE" />
			</AcctSvcrRef>
			<BkTxCd>
				<Prtry>
					<Cd>
						<xsl:choose>
							<xsl:when
								test="//TRANSACTIONCODE=210 or //TRANSACTIONCODE=212 or //TRANSACTIONCODE=220 or //TRANSACTIONCODE=222">
								<xsl:value-of select="'NTRF'" />
							</xsl:when>
							<xsl:when test="//TRANSACTIONCODE=230 or //TRANSACTIONCODE=232">
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
					<Amt>
						<xsl:attribute name="Ccy">
								<xsl:value-of select="CURRENCY" />
						    </xsl:attribute>
						<xsl:choose>
							<xsl:when test="AMOUNT &lt; 0">
								<xsl:value-of select="-1 * AMOUNT" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="AMOUNT" />
							</xsl:otherwise>
						</xsl:choose>
					</Amt>
					<CdtDbtInd>
						<xsl:choose>
							<xsl:when test="AMOUNT &gt;= 0">
								CRDT
							</xsl:when>
							<xsl:otherwise>
								DBIT
							</xsl:otherwise>
						</xsl:choose>
					</CdtDbtInd>
					<RmtInf>
						<Ustrd>
							<xsl:value-of select="TRANSACTIONDESCRIPTION" />
						</Ustrd>
						<Ustrd>
							<xsl:value-of select="TXNDETAILS" />
						</Ustrd>
					</RmtInf>
				</TxDtls>
			</NtryDtls>
		</Ntry>
	</xsl:template>


	<xsl:template name="yyyymmddToyyyy-mm-dd-format">
		<xsl:param name="origDateString" />

		<xsl:variable name="yr" select="substring($origDateString,1,4)" />
		<xsl:variable name="mo"
			select="concat('-',substring($origDateString,5,2))" />
		<xsl:variable name="dy"
			select="concat('-',substring($origDateString,7,2))" />

		<xsl:value-of select="concat($yr,concat($mo,$dy))" />

	</xsl:template>


</xsl:stylesheet>