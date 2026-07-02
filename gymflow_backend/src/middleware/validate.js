import { z } from 'zod';

export function validate(schema) {
  return (req, res, next) => {
    try {
      const parsed = schema.parse({
        body: req.body,
        query: req.query,
        params: req.params,
      });
      req.validated = parsed;
      next();
    } catch (err) {
      if (err instanceof z.ZodError) {
        return res.status(400).json({
          error: 'Validation failed',
          details: err.errors.map((e) => ({
            field: e.path.join('.'),
            message: e.message,
          })),
        });
      }
      next(err);
    }
  };
}

export const schemas = {
  register: z.object({
    body: z.object({
      email: z.string().email('Invalid email'),
      password: z.string().min(6, 'Password must be at least 6 characters'),
      full_name: z.string().min(2, 'Name must be at least 2 characters'),
      phone: z.string().optional(),
      role: z.enum(['admin', 'trainer', 'member']).default('member'),
    }),
  }),

  login: z.object({
    body: z.object({
      email: z.string().email(),
      password: z.string().min(1),
    }),
  }),

  createMember: z.object({
    body: z.object({
      email: z.string().email(),
      password: z.string().min(6).optional(),
      full_name: z.string().min(2),
      phone: z.string().optional(),
      gym_id: z.string().uuid(),
      membership_plan_id: z.string().uuid().optional(),
      start_date: z.string().optional(),
      assigned_trainer_id: z.string().uuid().optional(),
    }),
  }),

  createTrainer: z.object({
    body: z.object({
      email: z.string().email(),
      password: z.string().min(6).optional(),
      full_name: z.string().min(2),
      phone: z.string().optional(),
      gym_id: z.string().uuid(),
      specialization: z.string().optional(),
      hire_date: z.string().optional(),
      salary: z.number().positive().optional(),
    }),
  }),

  createPlan: z.object({
    body: z.object({
      gym_id: z.string().uuid(),
      name: z.string().min(2),
      duration_days: z.number().positive(),
      price: z.number().positive(),
      discounted_price: z.number().optional(),
      description: z.string().optional(),
      features: z.array(z.string()).optional(),
    }),
  }),

  createPayment: z.object({
    body: z.object({
      user_id: z.string().uuid(),
      gym_id: z.string().uuid(),
      membership_plan_id: z.string().uuid(),
      amount: z.number().positive(),
      method: z.enum(['cash', 'razorpay', 'upi', 'card', 'bank_transfer']),
      transaction_id: z.string().optional(),
    }),
  }),

  checkIn: z.object({
    body: z.object({
      gym_id: z.string().uuid(),
      method: z.enum(['qr', 'manual']).default('manual'),
      notes: z.string().optional(),
    }),
  }),

  createWorkout: z.object({
    body: z.object({
      gym_id: z.string().uuid(),
      member_id: z.string().uuid(),
      name: z.string().min(2),
      description: z.string().optional(),
      day_of_week: z.string().optional(),
      schedule_date: z.string().optional(),
      exercises: z.array(z.object({
        exercise_id: z.string().uuid(),
        sets: z.number().positive(),
        reps: z.number().positive(),
        weight: z.number().optional(),
        notes: z.string().optional(),
      })),
    }),
  }),

  createDiet: z.object({
    body: z.object({
      gym_id: z.string().uuid(),
      member_id: z.string().uuid(),
      name: z.string().min(2),
      type: z.enum(['weight_loss', 'muscle_gain', 'maintenance']),
      target_calories: z.number().optional(),
      meals: z.array(z.object({
        meal: z.string(),
        time: z.string(),
        foods: z.array(z.string()),
        calories: z.number().optional(),
      })),
    }),
  }),

  addProgress: z.object({
    body: z.object({
      weight: z.number().positive().optional(),
      bmi: z.number().positive().optional(),
      body_fat: z.number().optional(),
      chest_cm: z.number().optional(),
      waist_cm: z.number().optional(),
      arms_cm: z.number().optional(),
      thighs_cm: z.number().optional(),
      notes: z.string().optional(),
    }),
  }),
};
