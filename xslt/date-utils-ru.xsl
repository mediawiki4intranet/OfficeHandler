<?xml version="1.0"?>
<!--
    Copyright Roland Bouman
    Roland.Bouman@gmail.com
    http://rpbouman.blogspot.com/

    date-utils.xsl is an XSLT Stylesheet to do calculations on dates.
    (by date we mean strings formatted according to http://www.w3.org/TR/xmlschema-2/#date)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see http://www.gnu.org/licenses/

-->
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msp="http://schemas.microsoft.com/project"
>

<xsl:template name="make-date">
    <xsl:param name="year"/>
    <xsl:param name="month"/>
    <xsl:param name="day"/>
    <xsl:value-of select="concat($year, '-', $month, '-', $day)"/>
</xsl:template>

<xsl:template name="date-to-num">
    <xsl:param name="date"/>
    <xsl:variable name="year">
        <xsl:call-template name="get-year">
            <xsl:with-param name="date" select="$date"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="month">
        <xsl:call-template name="get-month">
            <xsl:with-param name="date" select="$date"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="day">
        <xsl:call-template name="get-day">
            <xsl:with-param name="date" select="$date"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="concat($year,$month,$day)"/>
</xsl:template>

<xsl:template name="date-least">
    <xsl:param name="date1"/>
    <xsl:param name="date2"/>
    <xsl:variable name="date1-num">
        <xsl:call-template name="date-to-num">
            <xsl:with-param name="date" select="$date1"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="date2-num">
        <xsl:call-template name="date-to-num">
            <xsl:with-param name="date" select="$date2"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
        <xsl:when test="$date1 &lt; $date2">
            <xsl:value-of select="$date1"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$date2"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="date-greatest">
    <xsl:param name="date1"/>
    <xsl:param name="date2"/>
    <xsl:variable name="date1-num">
        <xsl:call-template name="date-to-num">
            <xsl:with-param name="date" select="$date1"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="date2-num">
        <xsl:call-template name="date-to-num">
            <xsl:with-param name="date" select="$date2"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
        <xsl:when test="$date1 &gt; $date2">
            <xsl:value-of select="$date1"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$date2"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="get-year">
    <xsl:param name="date" select="."/>
    <xsl:value-of select="substring($date, 1, 4)"/>
</xsl:template>

<xsl:template name="get-month">
    <xsl:param name="date" select="."/>
    <xsl:value-of select="substring($date, 6, 2)"/>
</xsl:template>

<xsl:template name="get-day">
    <xsl:param name="date" select="."/>
    <xsl:value-of select="substring($date, 9, 2)"/>
</xsl:template>

<xsl:template name="num-dividable-by">
    <xsl:param name="num"/>
    <xsl:param name="by"/>
    <xsl:variable name="div" select="$num mod $by"/>
    <xsl:choose>
        <xsl:when test="$div = 0">1</xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="is-leap-year3">
    <xsl:param name="year" select="."/>

    <xsl:variable name="year-div400">
        <xsl:call-template name="num-dividable-by">
            <xsl:with-param name="num" select="$year"/>
            <xsl:with-param name="by" select="100"/>
        </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
        <xsl:when test="$year-div400=1">1</xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="is-leap-year2">
    <xsl:param name="year" select="."/>

    <xsl:variable name="year-div100">
        <xsl:call-template name="num-dividable-by">
            <xsl:with-param name="num" select="$year"/>
            <xsl:with-param name="by" select="100"/>
        </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
        <xsl:when test="$year-div100=1">
            <xsl:call-template name="is-leap-year3">
                <xsl:with-param name="year" select="$year"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="is-leap-year">
    <xsl:param name="year" select="."/>

    <xsl:variable name="year-div4">
        <xsl:call-template name="num-dividable-by">
            <xsl:with-param name="num" select="$year"/>
            <xsl:with-param name="by" select="4"/>
        </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
        <xsl:when test="$year-div4=1">
            <xsl:call-template name="is-leap-year2">
                <xsl:with-param name="year" select="$year"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="num-days-in-year">
    <xsl:param name="year"/>
    <xsl:variable name="is-leap-year">
        <xsl:call-template name="is-leap-year">
            <xsl:with-param name="year" select="$year"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="365 + $is-leap-year"/>
</xsl:template>

<xsl:template name="num-days-in-month">
    <xsl:param name="month" select="."/>
    <xsl:param name="year" select="."/>
    <xsl:choose>
        <xsl:when test="$month=1">31</xsl:when>
        <xsl:when test="$month=2">
            <xsl:variable name="is-leap-year">
                <xsl:call-template name="is-leap-year">
                    <xsl:with-param name="year" select="$year"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:value-of select="28 + $is-leap-year"/>
        </xsl:when>
        <xsl:when test="$month=3">31</xsl:when>
        <xsl:when test="$month=4">30</xsl:when>
        <xsl:when test="$month=5">31</xsl:when>
        <xsl:when test="$month=6">30</xsl:when>
        <xsl:when test="$month=7">31</xsl:when>
        <xsl:when test="$month=8">31</xsl:when>
        <xsl:when test="$month=9">30</xsl:when>
        <xsl:when test="$month=10">31</xsl:when>
        <xsl:when test="$month=11">30</xsl:when>
        <xsl:when test="$month=12">31</xsl:when>
    </xsl:choose>
</xsl:template>

<xsl:template name="first-of-month">
    <xsl:param name="date"/>
    <xsl:variable name="year">
        <xsl:call-template name="get-year">
            <xsl:with-param name="date" select="$date"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="month">
        <xsl:call-template name="get-month">
            <xsl:with-param name="date" select="$date"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="concat($year, '-', $month, '-01')"/>
</xsl:template>

<xsl:template name="last-of-month">
    <xsl:param name="date"/>
    <xsl:variable name="year">
        <xsl:call-template name="get-year">
            <xsl:with-param name="date" select="$date"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="month">
        <xsl:call-template name="get-month">
            <xsl:with-param name="date" select="$date"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="day">
        <xsl:call-template name="num-days-in-month">
            <xsl:with-param name="month" select="$month"/>
            <xsl:with-param name="year" select="$year"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="concat($year, '-', $month, '-', $day)"/>
</xsl:template>

<xsl:template name="num-days-in-year-up-to-date">
    <xsl:param name="date"/>
    <xsl:variable name="day">
        <xsl:call-template name="get-day">
            <xsl:with-param name="date" select="$date"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="month">
        <xsl:call-template name="get-month">
            <xsl:with-param name="date" select="$date"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="year">
        <xsl:call-template name="get-year">
            <xsl:with-param name="date" select="$date"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="is-leap-year">
        <xsl:call-template name="is-leap-year">
            <xsl:with-param name="year" select="number($year)"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="ly" select="number($is-leap-year)"/>
    <xsl:variable name="month-up-to" select="number($month) - 1"/>
    <xsl:variable name="days-in-months">
        <xsl:choose>
            <xsl:when test="$month-up-to= 0">0</xsl:when>
            <xsl:when test="$month-up-to= 1">31</xsl:when>
            <xsl:when test="$month-up-to= 2"><xsl:value-of select="31+28+$ly"/></xsl:when>
            <xsl:when test="$month-up-to= 3"><xsl:value-of select="31+28+$ly+31"/></xsl:when>
            <xsl:when test="$month-up-to= 4"><xsl:value-of select="31+28+$ly+31+30"/></xsl:when>
            <xsl:when test="$month-up-to= 5"><xsl:value-of select="31+28+$ly+31+30+31"/></xsl:when>
            <xsl:when test="$month-up-to= 6"><xsl:value-of select="31+28+$ly+31+30+31+30"/></xsl:when>
            <xsl:when test="$month-up-to= 7"><xsl:value-of select="31+28+$ly+31+30+31+30+31"/></xsl:when>
            <xsl:when test="$month-up-to= 8"><xsl:value-of select="31+28+$ly+31+30+31+30+31+31"/></xsl:when>
            <xsl:when test="$month-up-to= 9"><xsl:value-of select="31+28+$ly+31+30+31+30+31+31+30"/></xsl:when>
            <xsl:when test="$month-up-to=10"><xsl:value-of select="31+28+$ly+31+30+31+30+31+31+30+31"/></xsl:when>
            <xsl:when test="$month-up-to=11"><xsl:value-of select="31+28+$ly+31+30+31+30+31+31+30+31+30"/></xsl:when>
            <xsl:when test="$month-up-to=12"><xsl:value-of select="31+28+$ly+31+30+31+30+31+31+30+31+30+31"/></xsl:when>
        </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$days-in-months + $day"/>
</xsl:template>

<xsl:template name="get-month-abbr">
    <xsl:param name="month" select="."/>
    <xsl:choose>
        <xsl:when test="$month=1">Янв</xsl:when>
        <xsl:when test="$month=2">Фев</xsl:when>
        <xsl:when test="$month=3">Мар</xsl:when>
        <xsl:when test="$month=4">Апр</xsl:when>
        <xsl:when test="$month=5">Май</xsl:when>
        <xsl:when test="$month=6">Июн</xsl:when>
        <xsl:when test="$month=7">Июл</xsl:when>
        <xsl:when test="$month=8">Авг</xsl:when>
        <xsl:when test="$month=9">Сен</xsl:when>
        <xsl:when test="$month=10">Окт</xsl:when>
        <xsl:when test="$month=11">Ноя</xsl:when>
        <xsl:when test="$month=12">Дек</xsl:when>
    </xsl:choose>
</xsl:template>

<xsl:template name="days-in-years">
    <xsl:param name="from-year"/>
    <xsl:param name="to-year"/>
    <xsl:param name="days-so-far" select="0"/>
    <xsl:choose>
        <xsl:when test="$from-year &lt;= $to-year">
            <xsl:variable name="days-in-year">
                <xsl:call-template name="num-days-in-year">
                    <xsl:with-param name="year" select="$from-year"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:call-template name="days-in-years">
                <xsl:with-param name="from-year" select="$from-year + 1"/>
                <xsl:with-param name="to-year" select="$to-year"/>
                <xsl:with-param name="days-so-far" select="$days-so-far + $days-in-year"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$days-so-far"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="days-in-months">
    <xsl:param name="year"/>
    <xsl:param name="from-month"/>
    <xsl:param name="to-month"/>
    <xsl:param name="days-so-far" select="0"/>
    <xsl:choose>
        <xsl:when test="$from-month &lt;= $to-month">
            <xsl:variable name="days-in-month">
                <xsl:call-template name="num-days-in-month">
                    <xsl:with-param name="year" select="$year"/>
                    <xsl:with-param name="month" select="$from-month"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:call-template name="days-in-months">
                <xsl:with-param name="year" select="$year"/>
                <xsl:with-param name="from-month" select="$from-month + 1"/>
                <xsl:with-param name="to-month" select="$to-month"/>
                <xsl:with-param name="days-so-far" select="$days-so-far + $days-in-month"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$days-so-far"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="get-days-between">
    <xsl:param name="from-date"/>
    <xsl:param name="to-date"/>
    <xsl:variable name="from-year">
        <xsl:call-template name="get-year">
            <xsl:with-param name="date" select="$from-date"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="to-year">
        <xsl:call-template name="get-year">
            <xsl:with-param name="date" select="$to-date"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="num-days-in-year-up-to-from-date">
        <xsl:call-template name="num-days-in-year-up-to-date">
            <xsl:with-param name="date" select="$from-date"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="num-days-in-year-up-to-to-date">
        <xsl:call-template name="num-days-in-year-up-to-date">
            <xsl:with-param name="date" select="$to-date"/>
        </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
        <xsl:when test="$from-year = $to-year">
            <xsl:value-of select="$num-days-in-year-up-to-to-date - $num-days-in-year-up-to-from-date"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:variable name="num-days-in-from-year">
                <xsl:call-template name="num-days-in-year">
                    <xsl:with-param name="year" select="$from-year"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="num-days-beyond-from-date" select="$num-days-in-from-year - $num-days-in-year-up-to-from-date"/>
            <xsl:variable
                name="num-days-in-from-year-and-to-year"
                select="$num-days-in-from-year - $num-days-in-year-up-to-from-date + $num-days-in-year-up-to-to-date"
            />
            <xsl:choose>
                <xsl:when test="$to-year = $from-year + 1">
                    <xsl:value-of select="$num-days-in-from-year-and-to-year"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="days-in-years">
                        <xsl:call-template name="days-in-years">
                            <xsl:with-param name="from-year" select="$from-year + 1"/>
                            <xsl:with-param name="to-year" select="$to-year - 1"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:value-of select="$num-days-in-from-year-and-to-year + $days-in-years"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:otherwise>
    </xsl:choose>

</xsl:template>

</xsl:stylesheet>
