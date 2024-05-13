import multiprocessing

bind = "0.0.0.0:80"
workers = multiprocessing.cpu_count() * 2 + 1
access_log_format = '%({x-forwarded-for}i)s %(l)s %(l)s %(t)s "%(r)s" %(s)s %(b)s %(a)s'
accesslog = "-"
errorlog = "-"