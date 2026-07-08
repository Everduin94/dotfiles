# PR List Command

Lists open, non-draft PRs from the team created in the last 10 days. Includes CI check status and review decision.

```bash
gh pr list \
  --state open \
  --search "draft:false (author:everduin94 OR author:jdgarvey OR author:srqdeveloper OR author:ranyehushua OR author:vpenachi OR author:VicAv99 OR author:smithpb OR author:abaran30 OR author:csnow-cisco OR author:RaviTriv ) created:>=$(date -v-10d +%Y-%m-%d)" \
  --json number,title,author,createdAt,url,statusCheckRollup,reviewDecision \
  --jq '.[] | {
    number,
    title,
    author: .author.name,
    createdAt,
    url,
    checks: (
      if (.statusCheckRollup | length) == 0 then "none"
      elif (.statusCheckRollup | all(.conclusion == "SUCCESS")) then "passing"
      elif (.statusCheckRollup | any(.conclusion == "FAILURE")) then "failing"
      else "pending"
      end
    ),
    reviewDecision
  }'
```

## Fields

| Field            | Description                                                        |
| ---------------- | ------------------------------------------------------------------ |
| `checks`         | `passing`, `failing`, `pending`, or `none`                         |
| `reviewDecision` | `APPROVED`, `CHANGES_REQUESTED`, `REVIEW_REQUIRED`, or empty (`""`) |
