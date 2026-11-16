// Pure JSON bridge. Every I/O API returns a Promise and every result is a copy.
{
  const call = async (method, ...args) => {
    const r = JSON.parse(await __host(method, JSON.stringify(args)));
    if (!r.ok) {
      const e = new Error(r.error);
      e.code = r.error.split(':')[0];
      throw e;
    }
    return r.value;
  };
  const store = table => Object.freeze({
    get: async key => { const r = await call('kv.get', table, key); return r.found ? r.value : undefined; },
    set: (key, value) => call('kv.set', table, key, value),
    delete: key => call('kv.delete', table, key),
    list: (opts = {}) => call('kv.list', table, typeof opts === 'string' ? {prefix: opts} : opts)
  });
  globalThis.rofu = Object.freeze({
    invocation: Object.freeze(__invocation),
    conversation: Object.freeze({get: () => call('conversation.get')}),
    character: Object.freeze({get: () => call('character.get')}),
    context: Object.freeze({get: () => call('context.get')}),
    memory: Object.freeze({
      list: (opts = {}) => call('memory.list', opts),
      add: input => call('memory.add', input),
      update: (id, patch) => call('memory.update', id, patch),
      remove: id => call('memory.remove', id)
    }),
    messages: Object.freeze({
      list: (opts = {}) => call('messages.list', opts),
      get: id => call('messages.get', id),
      update: (id, patch) => call('messages.update', id, patch),
      insert: input => call('messages.insert', input),
      swipes: Object.freeze({
        list: id => call('swipes.list', id),
        append: (id, input, opts = {}) => call('swipes.append', id, input, opts),
        select: (id, index) => call('swipes.select', id, index),
        remove: (id, index) => call('swipes.remove', id, index)
      })
    }),
    kv: Object.freeze({...store('default'), table: name => store(name)}),
    http: Object.freeze({request: opts => call('http.request', opts)}),
    chat: Object.freeze({send: (content, opts = {}) => call('chat.send', content, opts)}),
    ui: Object.freeze({
      toast: (message, opts = {}) => call('ui.toast', message, opts),
      notify: opts => call('ui.notify', opts),
      dialog: opts => call('ui.dialog', opts)
    })
  });
  globalThis.console = Object.freeze(Object.fromEntries(['log','info','warn','error'].map(k => [k, () => {}])));
}
