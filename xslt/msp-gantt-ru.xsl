<?xml version="1.0"?>
<!--
    Copyright Roland Bouman
    Roland.Bouman@gmail.com
    http://rpbouman.blogspot.com/

    msp-gantt.xsl is an XSLT Stylesheet to render Microsoft Project 2003 XML format to a HTML gantt chart.

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
<xsl:param name="base" select="'..'"/>
<xsl:param name="css" select="concat($base, '/css/msp-outline.css')"/>
<xsl:param name="js" select="concat($base, '/js/msp-outline.js')"/>
<xsl:param name="show-links" select="true()"/>

<xsl:include href="date-utils-ru.xsl"/>

<xsl:output
    method="html"
    version="4.01"
    encoding="UTF-8"
    doctype-public="-//W3C//DTD HTML 4.01//EN"
    doctype-system="http://www.w3.org/TR/html4/strict.dtd"
    indent="yes"
    media-type="text/html"
/>

<xsl:variable name="project" select="msp:Project"/>
<xsl:variable name="tasks" select="$project/msp:Tasks/msp:Task"/>
<xsl:variable name="num-tasks" select="count($tasks)"/>
<xsl:variable name="assignments" select="$project/msp:Assignments/msp:Assignment"/>
<xsl:variable name="resources" select="$project/msp:Resources/msp:Resource"/>
<xsl:variable name="human-resources" select="$resources[msp:Type=1]"/>
<xsl:variable name="min-level" select="$tasks/msp:OutlineLevel[not(. &gt; $tasks/msp:OutlineLevel)]"/>

<xsl:variable name="calendar-start-date">
    <xsl:call-template name="first-of-month">
        <xsl:with-param name="date" select="$project/msp:StartDate"/>
    </xsl:call-template>
</xsl:variable>

<xsl:variable name="calendar-end-date">
    <xsl:call-template name="last-of-month">
        <xsl:with-param name="date" select="$project/msp:FinishDate"/>
    </xsl:call-template>
</xsl:variable>

<xsl:variable name="num-calendar-days">
    <xsl:call-template name="get-days-between">
        <xsl:with-param name="from-date" select="$calendar-start-date"/>
        <xsl:with-param name="to-date" select="$calendar-end-date"/>
    </xsl:call-template>
</xsl:variable>

<xsl:template match="/">
    <html>
        <head>
            <title><xsl:value-of select="$tasks[1]/msp:Name/text()"/></title>
            <link rel="stylesheet" type="text/css">
                <xsl:attribute name="href"><xsl:value-of select="$css"/></xsl:attribute>
            </link>
        </head>
        <body>
            <xsl:apply-templates select="msp:Project"/>
            <script type="text/javascript">
                <xsl:attribute name="src"><xsl:value-of select="$js"/></xsl:attribute>
            </script>
        </body>
    </html>
</xsl:template>

<xsl:template match="msp:Project">
    <table class="msp-tasks" cellpadding="0" cellspacing="0"    >
        <thead>
            <tr>
                <th></th>
                <th class="msp-outline-cell">Задача</th>
                <xsl:call-template name="task-calendar-heading"/>
            </tr>
        </thead>
        <tbody>
            <xsl:for-each select="msp:Tasks/msp:Task[msp:OutlineLevel = $min-level]">
                <xsl:call-template name="task-row">
                    <xsl:with-param
                        name="task"
                        select="."
                    />
                </xsl:call-template>
            </xsl:for-each>
        </tbody>
    </table>
</xsl:template>


<xsl:template name="task-row">
    <xsl:param name="task"/>

    <xsl:variable name="outline-level" select="number($task/msp:OutlineLevel)"/>
    <xsl:variable name="task-id" select="number($task/msp:ID)"/>
    <xsl:variable
        name="next-task"
        select="
            $tasks[
                number(msp:OutlineLevel) = $outline-level
            and number(msp:ID) &gt; $task-id
            ][1]
        "
    />
    <xsl:variable name="next-task-id" select="number($next-task/msp:ID)"/>
    <xsl:variable name="is-summary-task" select="$task/msp:Summary='1'"/>

    <tr>
        <xsl:attribute name="class">
            msp-task
            <xsl:if test="$is-summary-task">
                msp-summary-task
            </xsl:if>
        </xsl:attribute>
        <xsl:if test="$is-summary-task">
            <xsl:attribute name="onclick">
                 msp.outline.toggleTaskState(this);
            </xsl:attribute>
            <xsl:attribute name="level"><xsl:value-of select="$outline-level"/></xsl:attribute>
            <xsl:attribute name="task-id"><xsl:value-of select="$task-id"/></xsl:attribute>
            <xsl:attribute name="next-task-id"><xsl:value-of select="$next-task-id"/></xsl:attribute>
        </xsl:if>
        <td class="msp-task-id">
            <xsl:value-of select="$task-id + 1"/>
        </td>
        <td>
            <xsl:attribute name="style">
                background-position: <xsl:value-of select="$outline-level"/>em;
                text-indent: <xsl:value-of select=".75+ $outline-level"/>em;
            </xsl:attribute>
            <xsl:attribute name="class">
                msp-outline-cell
                <xsl:if test="$is-summary-task">
                    msp-collapse
                </xsl:if>
            </xsl:attribute>
            <xsl:value-of select="$task/msp:Name"/>
        </td>
        <xsl:call-template name="task-calendar">
            <xsl:with-param name="task" select="$task"/>
        </xsl:call-template>
    </tr>
    <xsl:if test="$is-summary-task">
        <xsl:for-each
            select="
                $tasks[
                     number(msp:ID) &gt; $task-id
                and (number(msp:ID) &lt; number($next-task-id) or count($next-task) = 0)
                and number(msp:OutlineLevel) = $outline-level + 1
                ]
            "
        >
            <xsl:call-template name="task-row">
                <xsl:with-param name="task" select="."/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:if>
</xsl:template>

<xsl:template name="task-resources">
    <xsl:param name="task"/>
    <xsl:variable name="task-uid" select="$task/msp:UID"/>
    <xsl:variable name="assignments" select="$assignments[msp:TaskUID=$task-uid]"/>
    <xsl:for-each select="$assignments">
        <xsl:variable name="resource-uid" select="msp:ResourceUID"/>
        <xsl:variable name="resource" select="$human-resources[msp:UID = $resource-uid]"/>
        <xsl:if test="position()!=1">;</xsl:if><xsl:value-of select="$resource/msp:Name"/>
    </xsl:for-each>
</xsl:template>

<xsl:template name="task-calendar">
    <xsl:param name="task"/>
    <xsl:variable name="is-summary-task" select="$task/msp:Summary='1'"/>
    <xsl:variable name="task-id" select="$task/msp:ID"/>
    <xsl:variable name="from-date" select="$task/msp:Start"/>
    <xsl:variable name="to-date" select="$task/msp:Finish"/>
    <xsl:variable name="days-to-from-date">
        <xsl:call-template name="get-days-between">
            <xsl:with-param name="from-date" select="$calendar-start-date"/>
            <xsl:with-param name="to-date" select="$from-date"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="days-in-timespan">
        <xsl:call-template name="get-days-between">
            <xsl:with-param name="from-date" select="$from-date"/>
            <xsl:with-param name="to-date" select="$to-date"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="start-of-timespan" select="100 * $days-to-from-date div $num-calendar-days"/>
    <xsl:variable name="end-of-timespan" select="100 * ($days-in-timespan + $days-to-from-date) div $num-calendar-days"/>
    <xsl:variable name="task-resources">
        <xsl:call-template name="task-resources">
            <xsl:with-param name="task" select="$task"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable
        name="title"
        select="
            concat(
                $task/msp:Name, ':'
            ,   '&#13;&#10;', substring-before($from-date, 'T'), ' / ', substring-before($to-date,'T')
            ,   '&#13;&#10;', $task-resources
            )
        "
    />
    <xsl:variable name="milestone" select="$task/msp:Milestone='1'"/>

    <td class="msp-outline-cell msp-task-calendar">
        <div class="msp-task-calendar">
            <div>
                <xsl:attribute name="title"><xsl:value-of select="$title"/></xsl:attribute>
                <xsl:attribute name="class">
                    <xsl:choose>
                        <xsl:when test="$milestone">
                            msp-milestone
                        </xsl:when>
                        <xsl:when test="$is-summary-task">
                            msp-timespan
                            msp-timespan-summary-task
                        </xsl:when>
                        <xsl:otherwise>
                            msp-timespan
                            msp-timespan-non-summary-task
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="style">
                    left: <xsl:value-of select="$start-of-timespan"/>%;
                    width: <xsl:value-of select="100 * $days-in-timespan div $num-calendar-days"/>%;
                </xsl:attribute>
                <xsl:if test="$milestone">&#9830;</xsl:if>
            </div>
            <div>
                <xsl:attribute name="class">
                    msp-timespan-resources
                </xsl:attribute>
                <xsl:attribute name="style">
                    left: <xsl:value-of select="$end-of-timespan"/>%;
                </xsl:attribute>
                <xsl:value-of select="$task-resources"/>
            </div>

            <xsl:if test="$show-links">
                <xsl:for-each select="$tasks/msp:PredecessorLink">
                    <xsl:variable name="type" select="msp:Type"/>
                    <xsl:variable name="other-task" select=".."/>
                    <xsl:variable name="other-task-id" select="$other-task/msp:ID"/>
                    <xsl:variable name="predecessor-uid" select="msp:PredecessorUID"/>
                    <xsl:variable name="predecessor" select="$tasks[msp:UID = $predecessor-uid]"/>
                    <xsl:variable name="predecessor-id" select="$predecessor/msp:ID"/>
                    <xsl:if
                        test="
                            $other-task-id  &lt;= $task-id
                        and $predecessor-id &gt;= $task-id
                        or  $predecessor-id &lt;= $task-id
                        and $other-task-id  &gt;= $task-id
                        "
                    >
                        <xsl:variable name="link-start-date">
                            <xsl:choose>
                                <xsl:when test="$type = 0 or $type = 1">
                                    <xsl:value-of select="$predecessor/msp:Finish"/>
                                </xsl:when>
                                <xsl:when test="$type = 2 or $type = 3">
                                    <xsl:value-of select="$predecessor/msp:Start"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="link-end-date">
                            <xsl:choose>
                                <xsl:when test="$type = 1 or $type = 3">
                                    <xsl:value-of select="$other-task/msp:Start"/>
                                </xsl:when>
                                <xsl:when test="$type = 0 or $type = 2">
                                    <xsl:value-of select="$other-task/msp:Finish"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="days-to-link-end">
                            <xsl:call-template name="get-days-between">
                                <xsl:with-param name="from-date" select="$calendar-start-date"/>
                                <xsl:with-param name="to-date" select="$link-end-date"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <div class="msp-link">
                            <xsl:attribute name="style">
                                <xsl:choose>
                                    <xsl:when test="$predecessor-id = $task-id">
                                        <xsl:variable name="days-to-link-start">
                                            <xsl:call-template name="get-days-between">
                                                <xsl:with-param name="from-date" select="$calendar-start-date"/>
                                                <xsl:with-param name="to-date" select="$link-start-date"/>
                                            </xsl:call-template>
                                        </xsl:variable>
                                        width: <xsl:value-of select="100.0 * ($days-to-link-end - $days-to-link-start) div $num-calendar-days"/>%;
                                        left: <xsl:value-of select="100.0 * $days-to-link-start div $num-calendar-days"/>%;
                                        <xsl:choose >
                                            <xsl:when test="$predecessor-id &lt; $other-task-id">
                                                border-top-style: solid;
                                                border-top-color: rgb(125,125,125);
                                            </xsl:when>
                                            <xsl:when test="$predecessor-id &gt; $other-task-id">
                                                border-bottom-style: solid;
                                                border-bottom-color: rgb(125,125,125);
                                                top: -1.5em;
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:when>
                                    <xsl:when test="$other-task-id = $task-id">
                                        left: <xsl:value-of select="100 * $days-to-link-end div $num-calendar-days"/>%;
                                        <xsl:choose>
                                            <xsl:when test="$predecessor-id &lt; $other-task-id">
                                                top: -1.5em;
                                            </xsl:when>
                                            <xsl:when test="$predecessor-id &gt; $other-task-id">
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        left: <xsl:value-of select="100 * $days-to-link-end div $num-calendar-days"/>%;
                                        top:-.75em;
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:if test="$task-id = $other-task-id">
                                <div class="msp-link-arrow">
                                    <xsl:choose>
                                        <xsl:when test="$predecessor-id &lt; $other-task-id">
                                        v
                                        </xsl:when>
                                        <xsl:when test="$predecessor-id &gt; $other-task-id">
                                        ^
                                        </xsl:when>
                                    </xsl:choose>
                                </div>
                            </xsl:if>
                        </div>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
        </div>
    </td>
</xsl:template>

<xsl:template name="task-calendar-year-headings">
    <xsl:param name="from-date" select="$calendar-start-date"/>
    <xsl:variable name="year">
        <xsl:call-template name="get-year">
            <xsl:with-param name="date" select="$from-date"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="last-year">
        <xsl:call-template name="get-year">
            <xsl:with-param name="date" select="$calendar-end-date"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="to-date">
        <xsl:choose>
            <xsl:when test="$year = $last-year">
                <xsl:value-of select="$calendar-end-date"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($year+1, '-01-01')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="timespan">
        <xsl:with-param name="from-date" select="$from-date"/>
        <xsl:with-param name="to-date" select="$to-date"/>
        <xsl:with-param name="class">
            msp-calendar-year
            <xsl:choose>
                <xsl:when test="$year mod 2 = 1">
                    msp-calendar-year-odd
                </xsl:when>
                <xsl:otherwise>
                    msp-calendar-year-even
                </xsl:otherwise>
            </xsl:choose>
        </xsl:with-param>
        <xsl:with-param name="content" select="$year"/>
    </xsl:call-template>
    <xsl:if test="$year != $last-year">
        <xsl:call-template name="task-calendar-year-headings">
            <xsl:with-param name="from-date" select="concat($year + 1, '-01-01')"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<xsl:template name="task-calendar-month-headings">
    <xsl:param name="from-date" select="$calendar-start-date"/>
    <xsl:variable name="to-date">
        <xsl:call-template name="last-of-month">
            <xsl:with-param name="date" select="$from-date"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="year">
        <xsl:call-template name="get-year">
            <xsl:with-param name="date" select="$from-date"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="month">
        <xsl:call-template name="get-month">
            <xsl:with-param name="date" select="$from-date"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="next-date">
        <xsl:choose>
            <xsl:when test="$month=12"><xsl:value-of select="concat($year + 1, '-01-01')"/></xsl:when>
            <xsl:otherwise>
                <xsl:variable name="month-plus-one" select="$month + 1"/>
                <xsl:variable name="next-month">
                    <xsl:choose>
                        <xsl:when test="$month-plus-one &lt; 10"><xsl:value-of select="concat('0', $month-plus-one)"/></xsl:when>
                        <xsl:otherwise><xsl:value-of select="$month-plus-one"/></xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:value-of select="concat($year, '-', $next-month, '-01')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:call-template name="timespan">
        <xsl:with-param name="from-date">
            <xsl:call-template name="first-of-month">
                <xsl:with-param name="date" select="$from-date"/>
            </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="to-date" select="$next-date"/>
        <xsl:with-param name="class">
            msp-calendar-month
            <xsl:choose>
                <xsl:when test="$month mod 2 = 1">
                    msp-calendar-month-odd
                </xsl:when>
                <xsl:otherwise>
                    msp-calendar-month-even
                </xsl:otherwise>
            </xsl:choose>
        </xsl:with-param>
        <xsl:with-param name="content">
            <xsl:call-template name="get-month-abbr">
                <xsl:with-param name="month" select="$month"/>
            </xsl:call-template>
        </xsl:with-param>
    </xsl:call-template>
    <xsl:if test="$to-date != $calendar-end-date">
        <xsl:call-template name="task-calendar-month-headings">
            <xsl:with-param name="from-date" select="$next-date"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<xsl:template name="task-calendar-heading">
    <th class="msp-outline-cell">
        <div class="msp-task-calendar">
            <xsl:call-template name="task-calendar-year-headings"/>
            <xsl:call-template name="task-calendar-month-headings"/>
        </div>
    </th>
</xsl:template>

<xsl:template name="timespan">
    <xsl:param name="from-date"/>
    <xsl:param name="to-date"/>
    <xsl:param name="class"/>
    <xsl:param name="title"/>
    <xsl:param name="content"/>
    <xsl:variable name="days-to-from-date">
        <xsl:call-template name="get-days-between">
            <xsl:with-param name="from-date" select="$calendar-start-date"/>
            <xsl:with-param name="to-date" select="$from-date"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="days-in-timespan">
        <xsl:call-template name="get-days-between">
            <xsl:with-param name="from-date" select="$from-date"/>
            <xsl:with-param name="to-date" select="$to-date"/>
        </xsl:call-template>
    </xsl:variable>
    <div>
        <xsl:attribute name="title">
            <xsl:value-of select="$title"/>
        </xsl:attribute>
        <xsl:attribute name="class">
            msp-timespan
            <xsl:value-of select="$class"/>
        </xsl:attribute>
        <xsl:attribute name="style">
            left: <xsl:value-of select="100 * $days-to-from-date div $num-calendar-days"/>%;
            width: <xsl:value-of select="100 * $days-in-timespan div $num-calendar-days"/>%;
        </xsl:attribute>
        <xsl:copy-of select="$content"/>
    </div>
</xsl:template>

</xsl:stylesheet>
