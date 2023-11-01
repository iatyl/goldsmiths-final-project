from concurrent import futures


def exec_in_thread(fn, /, *args, **kwargs):
    with futures.ThreadPoolExecutor() as executor:
        future = executor.submit(fn, *args, **kwargs)
        return future.result()


def sync_all_of(model, **filter_conditions):
    q = model.objects
    for k, v in filter_conditions.items():
        q = q.filter(**{k: v})
    return list(q.all())


def all_of(model, **filter_conditions):
    return exec_in_thread(sync_all_of, model=model, **filter_conditions)
