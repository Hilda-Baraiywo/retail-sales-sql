# Retail Sales Analysis — Management Insights

**Data basis:** 150 customers and 800 orders in the supplied datasets. All financial findings below use **Completed orders only**, apply the discount as a percentage, and use KSh. The figures were calculated from the supplied order and customer insert data.

## 1. Mobile Phones lead revenue, but Accessories have the strongest margin
**Queries:** Q16 and Q33

**Finding:** Mobile Phones generated the highest completed-order revenue at **KSh 6,942,060.65**. Computing followed at **KSh 6,596,221.70**. Accessories generated only **KSh 1,077,496.10** in revenue, but had the highest profit margin at **42.39%**. By comparison, the margin for Mobile Phones was **10.50%**.

**Why it matters:** The category with the highest sales is not necessarily the category with the strongest return on each shilling of revenue. Accessories contribute a relatively small share of sales but convert a much larger share of revenue into profit.

**Recommendation:** Maintain availability of high-revenue Mobile Phones and Computing products, while testing accessory bundles with phone and laptop purchases. Track whether bundles increase accessory sales without requiring discounts that erode the category's strong margin.

## 2. Nairobi is the largest sales market
**Query:** Q25

**Finding:** Nairobi generated **KSh 9,581,980.35**, equal to approximately **39.67%** of total completed-order revenue. Mombasa was the second-largest city at **KSh 3,161,889.60** (approximately **13.09%**).

**Why it matters:** A large share of revenue comes from one city. This makes Nairobi important to overall performance, but it also means that disruption or weaker demand in that market could have a significant effect on sales.

**Recommendation:** Protect service levels, stock availability and delivery performance in Nairobi. At the same time, test targeted campaigns and customer-retention activity in Mombasa and other towns to build a broader revenue base.

## 3. VIP customers have the highest average spending
**Query:** Q27

**Finding:** Average completed-order spending per customer was **KSh 253,251.88 for VIP**, **KSh 170,654.06 for Corporate**, and **KSh 141,123.71 for Retail** customers. VIP average spending was about **1.79 times** the Retail average.

**Why it matters:** The VIP segment has the highest average customer value, while the Corporate segment also spends more per customer on average than Retail. This suggests that different segments may respond to different retention and sales approaches.

**Recommendation:** Prioritise retention for VIP customers through reliable service and relevant product recommendations. Develop account-based offers for Corporate customers, and use accessible bundles or repeat-purchase campaigns to grow Retail customer value. Review the results regularly to see whether these activities increase completed-order spending.

## 4. A meaningful group of customers may need re-engagement
**Query:** Q34

**Finding:** **47 customers** had their latest Completed order more than 90 days before the dataset's latest order date, **30 September 2026**. That is **31.33% of the full 150-customer base**. Separately, **18 customers had no Completed orders**, so they do not appear in Q34's latest-completed-order result.

**Why it matters:** Customers who have not completed a purchase recently may be at risk of becoming inactive. Customers with no completed orders represent a separate group that may need onboarding or conversion support rather than a win-back campaign.

**Recommendation:** Create a re-engagement list for the 47 lapsed customers and prioritise outreach based on their previous spending. Investigate the 18 customers with no Completed orders separately; check whether they only placed Pending or Cancelled orders and whether there were barriers to completing a purchase.

## 5. Monthly revenue is volatile, with August 2026 as the strongest month
**Query:** Q40 (and Q31 for the highest-revenue month)

**Finding:** August 2026 was the strongest month in the dataset, with completed-order revenue of **KSh 2,242,033.90**. September 2026 generated **KSh 2,092,445.15**, a month-over-month decrease of approximately **6.67%**. Revenue also fell sharply from **KSh 2,027,120.60 in December 2025** to **KSh 322,432.95 in January 2026**, a decrease of approximately **84.09%**.

**Why it matters:** Revenue changes substantially from month to month. The December-to-January drop is particularly large and should be understood before management makes staffing, purchasing or sales-target decisions based on a single month.

**Recommendation:** Review the December 2025 and January 2026 order mix, completed-order volumes, stock availability and any promotional activity. Plan inventory and campaigns around observed demand, but do not assume the pattern is a recurring seasonal trend without comparing additional years of data.

## 6. The highest-spending third of customers contributes most revenue
**Query:** Q45

**Finding:** The `NTILE(3)` segmentation places 50 customers in each spending group. The High Value group generated **KSh 19,925,061.80**, approximately **82.49%** of completed-order revenue. The Medium Value group generated **KSh 3,813,905.25** (**15.79%**), while the Low Value group generated **KSh 416,404.65** (**1.72%**).

**Why it matters:** Revenue is highly concentrated among the top-spending third of customers. Losing a relatively small number of these customers could have a disproportionate effect on revenue.

**Recommendation:** Monitor repeat purchases and service issues among High Value customers, and use relevant cross-selling to retain them. Test low-cost campaigns that encourage Medium Value customers to make additional purchases. Avoid spending heavily to move every Low Value customer into a higher group without first checking their potential and acquisition or service cost.

## 7. Mobile Phones produce the highest total profit, while Accessories lead on margin
**Query:** Q33

**Finding:** Mobile Phones generated the highest total completed-order profit at **KSh 728,760.65**, followed by Computing at **KSh 700,021.70**. Accessories generated **KSh 456,746.10** in profit despite having the lowest category revenue, because its profit margin was **42.39%**.

**Why it matters:** Management should distinguish between total profit contribution and profit margin. Mobile Phones contribute the most profit in absolute terms, while Accessories earn the highest proportion of profit from each shilling of revenue.

**Recommendation:** Protect the availability and pricing discipline of Mobile Phones and Computing products because of their total profit contribution. For Accessories, investigate whether more units can be sold through relevant bundles and better product placement while preserving the margin.

---

## Method and interpretation notes

- Revenue = `quantity * unit_price * (1 - discount / 100)`.
- Cost = `quantity * cost_price`.
- Profit = `revenue - cost`.
- Profit margin = `profit / NULLIF(revenue, 0) * 100`.
- Financial calculations include Completed orders only.
- Q27 averages each customer's completed-order spending within their segment; customers with no Completed orders are included with spending of KSh 0.
- Q34 compares each customer's latest Completed order with the maximum `order_date` across **all** orders. Customers with no Completed orders are not returned by that query and are reported separately above.
- Q45 uses three approximately equal-sized groups based on completed-order spending, ordered from highest to lowest. The groups are relative to this dataset, not fixed KSh thresholds.
- Percentages are rounded to two decimal places, so displayed percentages may not sum to exactly 100%.
