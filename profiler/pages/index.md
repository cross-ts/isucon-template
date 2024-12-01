---
title: Dashboard
---

# Last Benchmark
## Access Log Profile

```sql alp
  select *, '<b>' || path || '</b>' as b_path from local.alp
```

<DataTable data={alp} rows=all rowShading=true>
  <Column id="b_path" title="Path" contentType=html/>
  <Column id="method" title="Method" />
  <Column id="count" title="Count" contentType=bar/>
  <Column id="sum_time" title="Sum Time" contentType=colorscale scaleColor={['#6db678','#ebbb38','#ce5050']}/>
  <Column id="avg_time" title="Avg Time" contentType=colorscale scaleColor={['#6db678','#ebbb38','#ce5050']}/>
  <Column id="sum_body_size" title="Sum Body Size" contentType=colorscale scaleColor={['#6db678','#ebbb38','#ce5050']}/>
  <Column id="avg_body_size" title="Avg Body Size" contentType=colorscale scaleColor={['#6db678','#ebbb38','#ce5050']}/>
  <Column id="200" title="2xx" contentType=colorscale scaleColor=blue/>
  <Column id="300" title="3xx" contentType=colorscale scaleColor=blue/>
  <Column id="400" title="4xx" contentType=colorscale scaleColor=blue/>
  <Column id="500" title="5xx" contentType=colorscale scaleColor=red/>
</DataTable>

## What's Next?
- [Connect your data sources](settings)
- Edit/add markdown files in the `pages` folder
- Deploy your project with [Evidence Cloud](https://evidence.dev/cloud)

## Get Support
- Message us on [Slack](https://slack.evidence.dev/)
- Read the [Docs](https://docs.evidence.dev/)
- Open an issue on [Github](https://github.com/evidence-dev/evidence)
