@PostMapping("/update-status/{id}/apply")
    public String applyStatusAndPriority(@PathVariable("id") Long id,
                                         @RequestParam(value = "status", required = false) Enrollment.Status newStatus,
                                         @RequestParam(value = "priority", required = false) Integer priority,
                                         @RequestParam(value = "failureReason", required = false) String failureReason,
                                         @RequestParam(value = "statusFilter", required = false) Enrollment.Status statusFilter,
                                         @RequestParam(value = "user", required = false) String user,
                                         @RequestParam(value = "env", required = false) String env,
                                         @RequestParam(value = "page", required = false, defaultValue = "0") int page,
                                         @RequestParam(value = "size", required = false, defaultValue = "25") int size) {
        service.updateStatusAndPriority(id, newStatus, priority, failureReason);
        StringBuilder redirect = new StringBuilder("redirect:/update-status?");
        if (statusFilter != null) redirect.append("status=").append(statusFilter.name()).append('&');
        if (user != null && !user.isBlank()) redirect.append("user=").append(user).append('&');
        if (env != null && !env.isBlank()) redirect.append("env=").append(env).append('&');
        redirect.append("page=").append(page).append('&');
        redirect.append("size=").append(size);
        return redirect.toString();
    }

    @Transactional
    public Enrollment updateStatusAndPriority(Long enrollmentId,
                                             Enrollment.Status newStatus,
                                             Integer priority,
                                             String failureReason) {
        Enrollment enrollment = repository.findById(enrollmentId)
            .orElseThrow(() -> new RuntimeException("Enrollment not found"));

        if (priority != null) {
            enrollment.setPriority(priority);
        }

        if (newStatus != null) {
            enrollment.setStatus(newStatus);
            if (newStatus == Enrollment.Status.COMPLETED) {
                enrollment.setCompletedAt(LocalDateTime.now());
            } else if (newStatus == Enrollment.Status.FAILED) {
                enrollment.setFailureReason(failureReason != null ? failureReason : "Unknown error");
            }
        }

        return repository.save(enrollment);
    }
