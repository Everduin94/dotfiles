```typescript
import { getRequestEvent, command } from "$app/server";

const schema = v.object({});

/*
 * DESCRIPTION_1
 */
export const NAME_2 = command(schema, async (params) => {
  const { cookies } = getRequestEvent();
  END_0;
});
```
