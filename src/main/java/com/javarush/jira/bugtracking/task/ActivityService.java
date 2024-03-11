package com.javarush.jira.bugtracking.task;

import com.javarush.jira.bugtracking.Handlers;
import com.javarush.jira.bugtracking.task.to.ActivityTo;
import com.javarush.jira.common.error.DataConflictException;
import com.javarush.jira.login.AuthUser;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

import static com.javarush.jira.bugtracking.task.TaskUtil.getLatestValue;

@Service
@RequiredArgsConstructor
public class ActivityService {
    private final TaskRepository taskRepository;

    private final Handlers.ActivityHandler handler;

    private static void checkBelong(HasAuthorId activity) {
        if (activity.getAuthorId() != AuthUser.authId()) {
            throw new DataConflictException("Activity " + activity.getId() + " doesn't belong to " + AuthUser.get());
        }
    }

    @Transactional
    public Activity create(ActivityTo activityTo) {
        checkBelong(activityTo);
        Task task = taskRepository.getExisted(activityTo.getTaskId());
        if (activityTo.getStatusCode() != null) {
            task.checkAndSetStatusCode(activityTo.getStatusCode());
        }
        if (activityTo.getTypeCode() != null) {
            task.setTypeCode(activityTo.getTypeCode());
        }
        return handler.createFromTo(activityTo);
    }

    @Transactional
    public void update(ActivityTo activityTo, long id) {
        checkBelong(handler.getRepository().getExisted(activityTo.getId()));
        handler.updateFromTo(activityTo, id);
        updateTaskIfRequired(activityTo.getTaskId(), activityTo.getStatusCode(), activityTo.getTypeCode());
    }

    @Transactional
    public void delete(long id) {
        Activity activity = handler.getRepository().getExisted(id);
        checkBelong(activity);
        handler.delete(activity.id());
        updateTaskIfRequired(activity.getTaskId(), activity.getStatusCode(), activity.getTypeCode());
    }

    private void updateTaskIfRequired(long taskId, String activityStatus, String activityType) {
        if (activityStatus != null || activityType != null) {
            Task task = taskRepository.getExisted(taskId);
            List<Activity> activities = handler.getRepository().findAllByTaskIdOrderByUpdatedDesc(task.id());
            if (activityStatus != null) {
                String latestStatus = getLatestValue(activities, Activity::getStatusCode);
                if (latestStatus == null) {
                    throw new DataConflictException("Primary activity cannot be delete or update with null values");
                }
                task.setStatusCode(latestStatus);
            }
            if (activityType != null) {
                String latestType = getLatestValue(activities, Activity::getTypeCode);
                if (latestType == null) {
                    throw new DataConflictException("Primary activity cannot be delete or update with null values");
                }
                task.setTypeCode(latestType);
            }
        }
    }

    // TODO 8 Добавить подсчет времени сколько задача находилась в работе и тестировании.
    //  Для тестирования через get запрос на сервер анотация @Transactional у методов:
    //  public Long getTaskInProgressDuration(Long taskId), public Long getTaskInTestingDuration(Long taskId)
    //  Логика такая, что рассчитывается время между первым in_progress и последним ready_for_review.
    //  Последним ready_for_review и последним done.

    private Long getTaskDuration(Long taskId, String activityFrom, String activityTo) {

        List<Activity> taskActivities = handler.getAll().
                stream().
                filter(a -> a.getTaskId().equals(taskId)).toList();

        if (taskActivities.size() < 2) {
            return 0L;
        }

        Comparator<Activity> activityComparator = (o1, o2) -> {
            assert o1.getUpdated() != null;
            assert o2.getUpdated() != null;
            return o1.getUpdated().compareTo(o2.getUpdated());
        };

        Activity firstActivity = null;

        if(activityFrom.equals("in_progress")) {
            firstActivity = taskActivities.
                    stream().
                    filter(a -> {
                        assert a.getStatusCode() != null;
                        return a.getStatusCode()
                                .equals(activityFrom);
                    }).
                    min(activityComparator).
                    orElse(null);
        } else if (activityFrom.equals("ready_for_review")) {
            firstActivity = taskActivities.
                    stream().
                    filter(a -> {
                        assert a.getStatusCode() != null;
                        return a.getStatusCode()
                                .equals(activityFrom);
                    }).
                    max(activityComparator).
                    orElse(null);
        }

        if (firstActivity == null) {
            return 0L;
        }

        Activity secondActivity = taskActivities.
                stream().
                filter(a -> {
                    assert a.getStatusCode() != null;
                    return a.getStatusCode()
                            .equals(activityTo);
                }).
                max(activityComparator).
                orElse(null);

        if (secondActivity == null) {
            return 0L;
        }

        assert firstActivity.getUpdated() != null;
        return Duration.between(firstActivity.getUpdated(), secondActivity.getUpdated()).getSeconds();

    }

    @Transactional
    public Long getTaskInProgressDuration(Long taskId){
        return getTaskDuration(taskId, "in_progress", "ready_for_review");
    }

    @Transactional
    public Long getTaskInTestingDuration(Long taskId){
        return getTaskDuration(taskId, "ready_for_review", "done");
    }


}
