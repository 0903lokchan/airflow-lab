from pendulum import datetime
from datetime import timedelta

from airflow.decorators import dag, task
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator


def say_hello():
    import logging

    logging.info("Hello World!")


@dag(
    dag_id="example_dag",
    schedule=timedelta(days=1),
    start_date=datetime(2023, 1, 1),
    catchup=False,
)
def example_dag():

    hello_python = PythonOperator(task_id="hello_python", python_callable=say_hello)
    goodbye_bash = BashOperator(task_id="bye", bash_command="echo Goodbye.")

    hello_python >> goodbye_bash


example_dag()
