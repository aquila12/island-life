# Copyright 2021 Nick Moriarty
#
# This file is provided under the terms of the Eclipse Public License, the full
# text of which can be found in EPL-2.0.txt in the licenses directory of this
# repository.

# Light wrapper around Fiber for scheduling maximum runtimes
class BackgroundTask
  def initialize(&block)
    @fiber = Fiber.new(&block)
  end

  # Schedule running for a maximum time in microseconds
  def time_slice(usecs)
    @start_time = Time.now.usec
    @time_limit = usecs

    @fiber.resume(self)
  end

  def time_up?
    t = Time.now.usec - @start_time
    t += 1000000 if t < 0

    t > @time_limit
  end

  # Give up the rest of the time slice
  def pause
    Fiber.yield
  end

  # End the time slice if it's finished
  def yield
    pause if time_up?
  end

  # True if the task hasn't completed
  def alive?
    @fiber.alive?
  end

  # True if the task has completed
  def done?
    !@fiber.alive?
  end
end
