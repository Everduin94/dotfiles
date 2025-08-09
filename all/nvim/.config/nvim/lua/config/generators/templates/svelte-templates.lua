local M = {}

local test = "this is my code i am"

function M.svelte_class(base_name, class_name)
  local template = [[
export type {class_name} = Tables<'{base_name}'>;

interface {class_name}StateOpts {
	data: {class_name}[];
	loading: boolean;
	error: string;
}

export class {class_name}State {
  data = $state<{class_name}[]>([]);
  loading = $state<'init' | 'loading' | 'stale' | 'error' | 'success'>('init');
  error = $state<string>('');

  constructor(opts: Partial<{class_name}StateOpts>) {
		if (opts.data) this.data = opts.data;
		if (opts.loading) this.loading = opts.loading;
		if (opts.error) this.error = opts.error;
  }

  async load() {
		const { supabase } = getSupabaseState();
		const { id, email } = getUserState();
		if (!id || !email) {
			return;
		}

		this.loading = true;
		const result = await supabase.from('{base_name}').select();
		if (result.data) {
			this.data = result.data;
		} else {
			this.error = result.error.message;
		}

		this.loading = false;
	}

  async add(item: Partial<{class_name}> = {}) {
		const { supabase } = getSupabaseState();
		const { id } = getUserState();
		if (!id) {
			return;
		}

		const new_item = {
			id: crypto.randomUUID(),
			user_id: id,
			...item
		};

		this.data.push(new_item);
		const result = await supabase.from('{base_name}').insert(new_item);
		if (result.error) {
			this.error = result.error.message;
			this.data.pop();
		}
	}

	async remove(item_id: string) {
		this.data = this.data.filter((d) => d.id !== item_id);

		const { supabase } = getSupabaseState();
		const { id } = getUserState();
		if (!id) {
			return;
		}

		const result = await supabase.from('{base_name}').delete().eq('id', item_id);
		if (result.error) {
			this.error = result.error.message;
		}
	}
}


let {base_name}_state: {class_name}State | null = $state(null);
export function set_{base_name}_state(opts: Partial<{class_name}StateOpts> = {}) {
	{base_name}_state = new {class_name}State(opts);
}
export function get_{base_name}_state(): {class_name}State {
	if (!{base_name}_state) throw new Error('Tried to access {class_name}State before set');
	return {base_name}_state;
}

]]

  template = template:gsub("{([%w_]+)}", { base_name = base_name, class_name = class_name })

  return { template = template }
end

function M.svelte_docs(file_name, base_name, class_name)
  local template = [[
# {class_name}

## Structure

- **󰆼 Database Table**: [{base_name}](https://supabase.com/dashboard/project/cvxvcjwuelzyhzzltenh/editor)
- ** Entry Component**: [{class_name}Entry](../components/{class_name}Entry.svelte)
- **󱃖 State**: [{class_name}State](../state/{file_name}-state.svelte.ts)

## Notes · Hacks · Edge Cases · Improvements

- **none**: (󰎚 Note)
- **none**: (󰈸 Hack)
- **none**: ( Edge Case)
- **none**: (󱕣 Improvement)

## Tasks

- [x] **none**: 

## Archived

```typescript
```
]]

  template = template:gsub("{([%w_]+)}", { file_name = file_name, base_name = base_name, class_name = class_name })

  return { template = template }
end

function M.svelte_entry_point(file_name, base_name, class_name)
  local template = [[
<script lang="ts">
	import { get_{class_name}_state } from '../state/{file_name}-state.svelte';

  let {}: {} = $props();
  let {base_name} = $derived(get_{class_name}_state())
</script>

<div class={['']}>

</div>
]]

  template = template:gsub("{([%w_]+)}", { file_name = file_name, base_name = base_name, class_name = class_name })

  return { template = template }
end

return M
