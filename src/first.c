#include "first.h"



void init(void* user_data) {
  sg_setup(&(sg_desc){});

  HMM_Vec2 a = { .X = 5, .Y = 10 };
  HMM_Vec2 b = { .X = 3, .Y = 11 };
  HMM_Vec2 out = HMM_AddV2(a, b);
  printf("Handmade Math: (%f, %f)\n", out.X, out.Y);
}

void frame(void* user_data) {
  sg_pass_action pass_action = {0};
  sg_begin_default_pass(&pass_action, sapp_width(), sapp_height());
  sg_end_pass();
  sg_commit();
}

void cleanup(void* user_data) {

}

void event(const sapp_event* event, void* user_data) {

}

sapp_desc sokol_main(int argc, char* argv[]) {
  return (sapp_desc) {
    .width = 640,
    .height = 480,
    .user_data = 0,
    .init_userdata_cb = init,
    .frame_userdata_cb = frame,
    .cleanup_userdata_cb = cleanup,
    .event_userdata_cb = event
  };
}