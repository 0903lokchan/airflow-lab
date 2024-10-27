import pytest
from pytest_mock import mocker, MockerFixture

from airflow.models import DagBag, DAG

from dags.example_dag import say_hello


@pytest.fixture()
def dagbag() -> DagBag:
    return DagBag()


@pytest.fixture()
def dag(dagbag) -> DAG:
    return dagbag.get_dag(dag_id="example_dag")


# parsing tests


def test_dag_loaded(dagbag):
    dag = dagbag.get_dag(dag_id="example_dag")
    assert dagbag.import_errors == {}
    assert dag is not None
    assert len(dag.tasks) == 2


# DAG structure tests


def assert_dag_dict_equal(source: dict, dag: DAG):
    assert dag.task_dict.keys() == source.keys()
    for task_id, downstream_list in source.items():
        assert dag.has_task(task_id)
        task = dag.get_task(task_id)
        assert task.downstream_task_ids == set(downstream_list)


def test_dag(dag: DAG):
    assert_dag_dict_equal(
        {
            "hello_python": ["goodbye_bash"],
            "goodbye_bash": [],
        },
        dag,
    )


# Python function tests


def test_say_hello(mocker):
    import logging

    mocker.patch("logging.info")
    say_hello()
    logging.info.assert_called_once_with("Hello World!")
