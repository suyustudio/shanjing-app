.class Lio/flutter/embedding/engine/c;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lb0/b;
.implements Lc0/b;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/embedding/engine/c$b;,
        Lio/flutter/embedding/engine/c$c;
    }
.end annotation


# instance fields
.field private final a:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Ljava/lang/Class<",
            "+",
            "Lb0/a;",
            ">;",
            "Lb0/a;",
            ">;"
        }
    .end annotation
.end field

.field private final b:Lio/flutter/embedding/engine/a;

.field private final c:Lb0/a$b;

.field private final d:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Ljava/lang/Class<",
            "+",
            "Lb0/a;",
            ">;",
            "Lc0/a;",
            ">;"
        }
    .end annotation
.end field

.field private e:Lio/flutter/embedding/android/d;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lio/flutter/embedding/android/d<",
            "Landroid/app/Activity;",
            ">;"
        }
    .end annotation
.end field

.field private f:Lio/flutter/embedding/engine/c$c;

.field private g:Z

.field private final h:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Ljava/lang/Class<",
            "+",
            "Lb0/a;",
            ">;",
            "Lg0/a;",
            ">;"
        }
    .end annotation
.end field

.field private i:Landroid/app/Service;

.field private final j:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Ljava/lang/Class<",
            "+",
            "Lb0/a;",
            ">;",
            "Ld0/a;",
            ">;"
        }
    .end annotation
.end field

.field private k:Landroid/content/BroadcastReceiver;

.field private final l:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Ljava/lang/Class<",
            "+",
            "Lb0/a;",
            ">;",
            "Le0/a;",
            ">;"
        }
    .end annotation
.end field

.field private m:Landroid/content/ContentProvider;


# direct methods
.method constructor <init>(Landroid/content/Context;Lio/flutter/embedding/engine/a;Lz/d;Lio/flutter/embedding/engine/d;)V
    .locals 9

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    iput-object v0, p0, Lio/flutter/embedding/engine/c;->a:Ljava/util/Map;

    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    iput-object v0, p0, Lio/flutter/embedding/engine/c;->d:Ljava/util/Map;

    const/4 v0, 0x0

    iput-boolean v0, p0, Lio/flutter/embedding/engine/c;->g:Z

    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    iput-object v0, p0, Lio/flutter/embedding/engine/c;->h:Ljava/util/Map;

    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    iput-object v0, p0, Lio/flutter/embedding/engine/c;->j:Ljava/util/Map;

    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    iput-object v0, p0, Lio/flutter/embedding/engine/c;->l:Ljava/util/Map;

    iput-object p2, p0, Lio/flutter/embedding/engine/c;->b:Lio/flutter/embedding/engine/a;

    new-instance v0, Lb0/a$b;

    invoke-virtual {p2}, Lio/flutter/embedding/engine/a;->j()Lx/a;

    move-result-object v4

    invoke-virtual {p2}, Lio/flutter/embedding/engine/a;->s()Lio/flutter/embedding/engine/renderer/FlutterRenderer;

    move-result-object v5

    invoke-virtual {p2}, Lio/flutter/embedding/engine/a;->p()Lio/flutter/plugin/platform/w;

    move-result-object v1

    invoke-virtual {v1}, Lio/flutter/plugin/platform/w;->W()Lio/flutter/plugin/platform/m;

    move-result-object v6

    new-instance v7, Lio/flutter/embedding/engine/c$b;

    const/4 v1, 0x0

    invoke-direct {v7, p3, v1}, Lio/flutter/embedding/engine/c$b;-><init>(Lz/d;Lio/flutter/embedding/engine/c$a;)V

    move-object v1, v0

    move-object v2, p1

    move-object v3, p2

    move-object v8, p4

    invoke-direct/range {v1 .. v8}, Lb0/a$b;-><init>(Landroid/content/Context;Lio/flutter/embedding/engine/a;Lj0/c;Lio/flutter/view/TextureRegistry;Lio/flutter/plugin/platform/m;Lb0/a$a;Lio/flutter/embedding/engine/d;)V

    iput-object v0, p0, Lio/flutter/embedding/engine/c;->c:Lb0/a$b;

    return-void
.end method

.method private k(Landroid/app/Activity;Landroidx/lifecycle/d;)V
    .locals 3

    new-instance v0, Lio/flutter/embedding/engine/c$c;

    invoke-direct {v0, p1, p2}, Lio/flutter/embedding/engine/c$c;-><init>(Landroid/app/Activity;Landroidx/lifecycle/d;)V

    iput-object v0, p0, Lio/flutter/embedding/engine/c;->f:Lio/flutter/embedding/engine/c$c;

    invoke-virtual {p1}, Landroid/app/Activity;->getIntent()Landroid/content/Intent;

    move-result-object p2

    const/4 v0, 0x0

    if-eqz p2, :cond_0

    invoke-virtual {p1}, Landroid/app/Activity;->getIntent()Landroid/content/Intent;

    move-result-object p2

    const-string v1, "enable-software-rendering"

    invoke-virtual {p2, v1, v0}, Landroid/content/Intent;->getBooleanExtra(Ljava/lang/String;Z)Z

    move-result p2

    goto :goto_0

    :cond_0
    const/4 p2, 0x0

    :goto_0
    iget-object v1, p0, Lio/flutter/embedding/engine/c;->b:Lio/flutter/embedding/engine/a;

    invoke-virtual {v1}, Lio/flutter/embedding/engine/a;->p()Lio/flutter/plugin/platform/w;

    move-result-object v1

    invoke-virtual {v1, p2}, Lio/flutter/plugin/platform/w;->s0(Z)V

    iget-object p2, p0, Lio/flutter/embedding/engine/c;->b:Lio/flutter/embedding/engine/a;

    invoke-virtual {p2}, Lio/flutter/embedding/engine/a;->p()Lio/flutter/plugin/platform/w;

    move-result-object p2

    iget-object v1, p0, Lio/flutter/embedding/engine/c;->b:Lio/flutter/embedding/engine/a;

    invoke-virtual {v1}, Lio/flutter/embedding/engine/a;->s()Lio/flutter/embedding/engine/renderer/FlutterRenderer;

    move-result-object v1

    iget-object v2, p0, Lio/flutter/embedding/engine/c;->b:Lio/flutter/embedding/engine/a;

    invoke-virtual {v2}, Lio/flutter/embedding/engine/a;->j()Lx/a;

    move-result-object v2

    invoke-virtual {p2, p1, v1, v2}, Lio/flutter/plugin/platform/w;->C(Landroid/content/Context;Lio/flutter/view/TextureRegistry;Lx/a;)V

    iget-object p1, p0, Lio/flutter/embedding/engine/c;->d:Ljava/util/Map;

    invoke-interface {p1}, Ljava/util/Map;->values()Ljava/util/Collection;

    move-result-object p1

    invoke-interface {p1}, Ljava/util/Collection;->iterator()Ljava/util/Iterator;

    move-result-object p1

    :goto_1
    invoke-interface {p1}, Ljava/util/Iterator;->hasNext()Z

    move-result p2

    if-eqz p2, :cond_2

    invoke-interface {p1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object p2

    check-cast p2, Lc0/a;

    iget-boolean v1, p0, Lio/flutter/embedding/engine/c;->g:Z

    if-eqz v1, :cond_1

    iget-object v1, p0, Lio/flutter/embedding/engine/c;->f:Lio/flutter/embedding/engine/c$c;

    invoke-interface {p2, v1}, Lc0/a;->h(Lc0/c;)V

    goto :goto_1

    :cond_1
    iget-object v1, p0, Lio/flutter/embedding/engine/c;->f:Lio/flutter/embedding/engine/c$c;

    invoke-interface {p2, v1}, Lc0/a;->d(Lc0/c;)V

    goto :goto_1

    :cond_2
    iput-boolean v0, p0, Lio/flutter/embedding/engine/c;->g:Z

    return-void
.end method

.method private m()V
    .locals 1

    iget-object v0, p0, Lio/flutter/embedding/engine/c;->b:Lio/flutter/embedding/engine/a;

    invoke-virtual {v0}, Lio/flutter/embedding/engine/a;->p()Lio/flutter/plugin/platform/w;

    move-result-object v0

    invoke-virtual {v0}, Lio/flutter/plugin/platform/w;->O()V

    const/4 v0, 0x0

    iput-object v0, p0, Lio/flutter/embedding/engine/c;->e:Lio/flutter/embedding/android/d;

    iput-object v0, p0, Lio/flutter/embedding/engine/c;->f:Lio/flutter/embedding/engine/c$c;

    return-void
.end method

.method private n()V
    .locals 1

    invoke-direct {p0}, Lio/flutter/embedding/engine/c;->s()Z

    move-result v0

    if-eqz v0, :cond_0

    invoke-virtual {p0}, Lio/flutter/embedding/engine/c;->j()V

    goto :goto_0

    :cond_0
    invoke-direct {p0}, Lio/flutter/embedding/engine/c;->v()Z

    move-result v0

    if-eqz v0, :cond_1

    invoke-virtual {p0}, Lio/flutter/embedding/engine/c;->q()V

    goto :goto_0

    :cond_1
    invoke-direct {p0}, Lio/flutter/embedding/engine/c;->t()Z

    move-result v0

    if-eqz v0, :cond_2

    invoke-virtual {p0}, Lio/flutter/embedding/engine/c;->o()V

    goto :goto_0

    :cond_2
    invoke-direct {p0}, Lio/flutter/embedding/engine/c;->u()Z

    move-result v0

    if-eqz v0, :cond_3

    invoke-virtual {p0}, Lio/flutter/embedding/engine/c;->p()V

    :cond_3
    :goto_0
    return-void
.end method

.method private s()Z
    .locals 1

    iget-object v0, p0, Lio/flutter/embedding/engine/c;->e:Lio/flutter/embedding/android/d;

    if-eqz v0, :cond_0

    const/4 v0, 0x1

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    :goto_0
    return v0
.end method

.method private t()Z
    .locals 1

    iget-object v0, p0, Lio/flutter/embedding/engine/c;->k:Landroid/content/BroadcastReceiver;

    if-eqz v0, :cond_0

    const/4 v0, 0x1

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    :goto_0
    return v0
.end method

.method private u()Z
    .locals 1

    iget-object v0, p0, Lio/flutter/embedding/engine/c;->m:Landroid/content/ContentProvider;

    if-eqz v0, :cond_0

    const/4 v0, 0x1

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    :goto_0
    return v0
.end method

.method private v()Z
    .locals 1

    iget-object v0, p0, Lio/flutter/embedding/engine/c;->i:Landroid/app/Service;

    if-eqz v0, :cond_0

    const/4 v0, 0x1

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    :goto_0
    return v0
.end method


# virtual methods
.method public a(I[Ljava/lang/String;[I)Z
    .locals 2

    invoke-direct {p0}, Lio/flutter/embedding/engine/c;->s()Z

    move-result v0

    if-eqz v0, :cond_2

    const-string v0, "FlutterEngineConnectionRegistry#onRequestPermissionsResult"

    invoke-static {v0}, Lp0/f;->f(Ljava/lang/String;)Lp0/f;

    move-result-object v0

    :try_start_0
    iget-object v1, p0, Lio/flutter/embedding/engine/c;->f:Lio/flutter/embedding/engine/c$c;

    invoke-virtual {v1, p1, p2, p3}, Lio/flutter/embedding/engine/c$c;->i(I[Ljava/lang/String;[I)Z

    move-result p1
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Lp0/f;->close()V

    :cond_0
    return p1

    :catchall_0
    move-exception p1

    if-eqz v0, :cond_1

    :try_start_1
    invoke-virtual {v0}, Lp0/f;->close()V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    goto :goto_0

    :catchall_1
    move-exception p2

    invoke-virtual {p1, p2}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :cond_1
    :goto_0
    throw p1

    :cond_2
    const-string p1, "FlutterEngineCxnRegstry"

    const-string p2, "Attempted to notify ActivityAware plugins of onRequestPermissionsResult, but no Activity was attached."

    invoke-static {p1, p2}, Lw/b;->b(Ljava/lang/String;Ljava/lang/String;)V

    const/4 p1, 0x0

    return p1
.end method

.method public b(IILandroid/content/Intent;)Z
    .locals 2

    invoke-direct {p0}, Lio/flutter/embedding/engine/c;->s()Z

    move-result v0

    if-eqz v0, :cond_2

    const-string v0, "FlutterEngineConnectionRegistry#onActivityResult"

    invoke-static {v0}, Lp0/f;->f(Ljava/lang/String;)Lp0/f;

    move-result-object v0

    :try_start_0
    iget-object v1, p0, Lio/flutter/embedding/engine/c;->f:Lio/flutter/embedding/engine/c$c;

    invoke-virtual {v1, p1, p2, p3}, Lio/flutter/embedding/engine/c$c;->b(IILandroid/content/Intent;)Z

    move-result p1
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Lp0/f;->close()V

    :cond_0
    return p1

    :catchall_0
    move-exception p1

    if-eqz v0, :cond_1

    :try_start_1
    invoke-virtual {v0}, Lp0/f;->close()V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    goto :goto_0

    :catchall_1
    move-exception p2

    invoke-virtual {p1, p2}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :cond_1
    :goto_0
    throw p1

    :cond_2
    const-string p1, "FlutterEngineCxnRegstry"

    const-string p2, "Attempted to notify ActivityAware plugins of onActivityResult, but no Activity was attached."

    invoke-static {p1, p2}, Lw/b;->b(Ljava/lang/String;Ljava/lang/String;)V

    const/4 p1, 0x0

    return p1
.end method

.method public c(Landroid/content/Intent;)V
    .locals 2

    invoke-direct {p0}, Lio/flutter/embedding/engine/c;->s()Z

    move-result v0

    if-eqz v0, :cond_1

    const-string v0, "FlutterEngineConnectionRegistry#onNewIntent"

    invoke-static {v0}, Lp0/f;->f(Ljava/lang/String;)Lp0/f;

    move-result-object v0

    :try_start_0
    iget-object v1, p0, Lio/flutter/embedding/engine/c;->f:Lio/flutter/embedding/engine/c$c;

    invoke-virtual {v1, p1}, Lio/flutter/embedding/engine/c$c;->c(Landroid/content/Intent;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    if-eqz v0, :cond_2

    invoke-virtual {v0}, Lp0/f;->close()V

    goto :goto_1

    :catchall_0
    move-exception p1

    if-eqz v0, :cond_0

    :try_start_1
    invoke-virtual {v0}, Lp0/f;->close()V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    goto :goto_0

    :catchall_1
    move-exception v0

    invoke-virtual {p1, v0}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :cond_0
    :goto_0
    throw p1

    :cond_1
    const-string p1, "FlutterEngineCxnRegstry"

    const-string v0, "Attempted to notify ActivityAware plugins of onNewIntent, but no Activity was attached."

    invoke-static {p1, v0}, Lw/b;->b(Ljava/lang/String;Ljava/lang/String;)V

    :cond_2
    :goto_1
    return-void
.end method

.method public d(Landroid/os/Bundle;)V
    .locals 2

    invoke-direct {p0}, Lio/flutter/embedding/engine/c;->s()Z

    move-result v0

    if-eqz v0, :cond_1

    const-string v0, "FlutterEngineConnectionRegistry#onRestoreInstanceState"

    invoke-static {v0}, Lp0/f;->f(Ljava/lang/String;)Lp0/f;

    move-result-object v0

    :try_start_0
    iget-object v1, p0, Lio/flutter/embedding/engine/c;->f:Lio/flutter/embedding/engine/c$c;

    invoke-virtual {v1, p1}, Lio/flutter/embedding/engine/c$c;->j(Landroid/os/Bundle;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    if-eqz v0, :cond_2

    invoke-virtual {v0}, Lp0/f;->close()V

    goto :goto_1

    :catchall_0
    move-exception p1

    if-eqz v0, :cond_0

    :try_start_1
    invoke-virtual {v0}, Lp0/f;->close()V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    goto :goto_0

    :catchall_1
    move-exception v0

    invoke-virtual {p1, v0}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :cond_0
    :goto_0
    throw p1

    :cond_1
    const-string p1, "FlutterEngineCxnRegstry"

    const-string v0, "Attempted to notify ActivityAware plugins of onRestoreInstanceState, but no Activity was attached."

    invoke-static {p1, v0}, Lw/b;->b(Ljava/lang/String;Ljava/lang/String;)V

    :cond_2
    :goto_1
    return-void
.end method

.method public e(Landroid/os/Bundle;)V
    .locals 2

    invoke-direct {p0}, Lio/flutter/embedding/engine/c;->s()Z

    move-result v0

    if-eqz v0, :cond_1

    const-string v0, "FlutterEngineConnectionRegistry#onSaveInstanceState"

    invoke-static {v0}, Lp0/f;->f(Ljava/lang/String;)Lp0/f;

    move-result-object v0

    :try_start_0
    iget-object v1, p0, Lio/flutter/embedding/engine/c;->f:Lio/flutter/embedding/engine/c$c;

    invoke-virtual {v1, p1}, Lio/flutter/embedding/engine/c$c;->k(Landroid/os/Bundle;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    if-eqz v0, :cond_2

    invoke-virtual {v0}, Lp0/f;->close()V

    goto :goto_1

    :catchall_0
    move-exception p1

    if-eqz v0, :cond_0

    :try_start_1
    invoke-virtual {v0}, Lp0/f;->close()V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    goto :goto_0

    :catchall_1
    move-exception v0

    invoke-virtual {p1, v0}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :cond_0
    :goto_0
    throw p1

    :cond_1
    const-string p1, "FlutterEngineCxnRegstry"

    const-string v0, "Attempted to notify ActivityAware plugins of onSaveInstanceState, but no Activity was attached."

    invoke-static {p1, v0}, Lw/b;->b(Ljava/lang/String;Ljava/lang/String;)V

    :cond_2
    :goto_1
    return-void
.end method

.method public f()V
    .locals 2

    invoke-direct {p0}, Lio/flutter/embedding/engine/c;->s()Z

    move-result v0

    if-eqz v0, :cond_1

    const-string v0, "FlutterEngineConnectionRegistry#onUserLeaveHint"

    invoke-static {v0}, Lp0/f;->f(Ljava/lang/String;)Lp0/f;

    move-result-object v0

    :try_start_0
    iget-object v1, p0, Lio/flutter/embedding/engine/c;->f:Lio/flutter/embedding/engine/c$c;

    invoke-virtual {v1}, Lio/flutter/embedding/engine/c$c;->l()V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    if-eqz v0, :cond_2

    invoke-virtual {v0}, Lp0/f;->close()V

    goto :goto_1

    :catchall_0
    move-exception v1

    if-eqz v0, :cond_0

    :try_start_1
    invoke-virtual {v0}, Lp0/f;->close()V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    goto :goto_0

    :catchall_1
    move-exception v0

    invoke-virtual {v1, v0}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :cond_0
    :goto_0
    throw v1

    :cond_1
    const-string v0, "FlutterEngineCxnRegstry"

    const-string v1, "Attempted to notify ActivityAware plugins of onUserLeaveHint, but no Activity was attached."

    invoke-static {v0, v1}, Lw/b;->b(Ljava/lang/String;Ljava/lang/String;)V

    :cond_2
    :goto_1
    return-void
.end method

.method public g(Lb0/a;)V
    .locals 5

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "FlutterEngineConnectionRegistry#add "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Class;->getSimpleName()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lp0/f;->f(Ljava/lang/String;)Lp0/f;

    move-result-object v0

    :try_start_0
    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v1

    invoke-virtual {p0, v1}, Lio/flutter/embedding/engine/c;->r(Ljava/lang/Class;)Z

    move-result v1
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    const-string v2, "FlutterEngineCxnRegstry"

    if-eqz v1, :cond_1

    :try_start_1
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "Attempted to register plugin ("

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    const-string p1, ") but it was already registered with this FlutterEngine ("

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object p1, p0, Lio/flutter/embedding/engine/c;->b:Lio/flutter/embedding/engine/a;

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    const-string p1, ")."

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {v2, p1}, Lw/b;->g(Ljava/lang/String;Ljava/lang/String;)V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Lp0/f;->close()V

    :cond_0
    return-void

    :cond_1
    :try_start_2
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "Adding plugin: "

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v2, v1}, Lw/b;->f(Ljava/lang/String;Ljava/lang/String;)V

    iget-object v1, p0, Lio/flutter/embedding/engine/c;->a:Ljava/util/Map;

    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v2

    invoke-interface {v1, v2, p1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    iget-object v1, p0, Lio/flutter/embedding/engine/c;->c:Lb0/a$b;

    invoke-interface {p1, v1}, Lb0/a;->i(Lb0/a$b;)V

    instance-of v1, p1, Lc0/a;

    if-eqz v1, :cond_2

    move-object v1, p1

    check-cast v1, Lc0/a;

    iget-object v2, p0, Lio/flutter/embedding/engine/c;->d:Ljava/util/Map;

    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v3

    invoke-interface {v2, v3, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    invoke-direct {p0}, Lio/flutter/embedding/engine/c;->s()Z

    move-result v2

    if-eqz v2, :cond_2

    iget-object v2, p0, Lio/flutter/embedding/engine/c;->f:Lio/flutter/embedding/engine/c$c;

    invoke-interface {v1, v2}, Lc0/a;->d(Lc0/c;)V

    :cond_2
    instance-of v1, p1, Lg0/a;

    const/4 v2, 0x0

    if-eqz v1, :cond_3

    move-object v1, p1

    check-cast v1, Lg0/a;

    iget-object v3, p0, Lio/flutter/embedding/engine/c;->h:Ljava/util/Map;

    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v4

    invoke-interface {v3, v4, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    invoke-direct {p0}, Lio/flutter/embedding/engine/c;->v()Z

    move-result v3

    if-eqz v3, :cond_3

    invoke-interface {v1, v2}, Lg0/a;->b(Lg0/b;)V

    :cond_3
    instance-of v1, p1, Ld0/a;

    if-eqz v1, :cond_4

    move-object v1, p1

    check-cast v1, Ld0/a;

    iget-object v3, p0, Lio/flutter/embedding/engine/c;->j:Ljava/util/Map;

    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v4

    invoke-interface {v3, v4, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    invoke-direct {p0}, Lio/flutter/embedding/engine/c;->t()Z

    move-result v3

    if-eqz v3, :cond_4

    invoke-interface {v1, v2}, Ld0/a;->a(Ld0/b;)V

    :cond_4
    instance-of v1, p1, Le0/a;

    if-eqz v1, :cond_5

    move-object v1, p1

    check-cast v1, Le0/a;

    iget-object v3, p0, Lio/flutter/embedding/engine/c;->l:Ljava/util/Map;

    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object p1

    invoke-interface {v3, p1, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    invoke-direct {p0}, Lio/flutter/embedding/engine/c;->u()Z

    move-result p1

    if-eqz p1, :cond_5

    invoke-interface {v1, v2}, Le0/a;->b(Le0/b;)V
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    :cond_5
    if-eqz v0, :cond_6

    invoke-virtual {v0}, Lp0/f;->close()V

    :cond_6
    return-void

    :catchall_0
    move-exception p1

    if-eqz v0, :cond_7

    :try_start_3
    invoke-virtual {v0}, Lp0/f;->close()V
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_1

    goto :goto_0

    :catchall_1
    move-exception v0

    invoke-virtual {p1, v0}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :cond_7
    :goto_0
    throw p1
.end method

.method public h(Lio/flutter/embedding/android/d;Landroidx/lifecycle/d;)V
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lio/flutter/embedding/android/d<",
            "Landroid/app/Activity;",
            ">;",
            "Landroidx/lifecycle/d;",
            ")V"
        }
    .end annotation

    const-string v0, "FlutterEngineConnectionRegistry#attachToActivity"

    invoke-static {v0}, Lp0/f;->f(Ljava/lang/String;)Lp0/f;

    move-result-object v0

    :try_start_0
    iget-object v1, p0, Lio/flutter/embedding/engine/c;->e:Lio/flutter/embedding/android/d;

    if-eqz v1, :cond_0

    invoke-interface {v1}, Lio/flutter/embedding/android/d;->e()V

    :cond_0
    invoke-direct {p0}, Lio/flutter/embedding/engine/c;->n()V

    iput-object p1, p0, Lio/flutter/embedding/engine/c;->e:Lio/flutter/embedding/android/d;

    invoke-interface {p1}, Lio/flutter/embedding/android/d;->f()Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Landroid/app/Activity;

    invoke-direct {p0, p1, p2}, Lio/flutter/embedding/engine/c;->k(Landroid/app/Activity;Landroidx/lifecycle/d;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    if-eqz v0, :cond_1

    invoke-virtual {v0}, Lp0/f;->close()V

    :cond_1
    return-void

    :catchall_0
    move-exception p1

    if-eqz v0, :cond_2

    :try_start_1
    invoke-virtual {v0}, Lp0/f;->close()V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    goto :goto_0

    :catchall_1
    move-exception p2

    invoke-virtual {p1, p2}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :cond_2
    :goto_0
    throw p1
.end method

.method public i()V
    .locals 3

    invoke-direct {p0}, Lio/flutter/embedding/engine/c;->s()Z

    move-result v0

    if-eqz v0, :cond_2

    const-string v0, "FlutterEngineConnectionRegistry#detachFromActivityForConfigChanges"

    invoke-static {v0}, Lp0/f;->f(Ljava/lang/String;)Lp0/f;

    move-result-object v0

    const/4 v1, 0x1

    :try_start_0
    iput-boolean v1, p0, Lio/flutter/embedding/engine/c;->g:Z

    iget-object v1, p0, Lio/flutter/embedding/engine/c;->d:Ljava/util/Map;

    invoke-interface {v1}, Ljava/util/Map;->values()Ljava/util/Collection;

    move-result-object v1

    invoke-interface {v1}, Ljava/util/Collection;->iterator()Ljava/util/Iterator;

    move-result-object v1

    :goto_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_0

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lc0/a;

    invoke-interface {v2}, Lc0/a;->g()V

    goto :goto_0

    :cond_0
    invoke-direct {p0}, Lio/flutter/embedding/engine/c;->m()V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    if-eqz v0, :cond_3

    invoke-virtual {v0}, Lp0/f;->close()V

    goto :goto_2

    :catchall_0
    move-exception v1

    if-eqz v0, :cond_1

    :try_start_1
    invoke-virtual {v0}, Lp0/f;->close()V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    goto :goto_1

    :catchall_1
    move-exception v0

    invoke-virtual {v1, v0}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :cond_1
    :goto_1
    throw v1

    :cond_2
    const-string v0, "FlutterEngineCxnRegstry"

    const-string v1, "Attempted to detach plugins from an Activity when no Activity was attached."

    invoke-static {v0, v1}, Lw/b;->b(Ljava/lang/String;Ljava/lang/String;)V

    :cond_3
    :goto_2
    return-void
.end method

.method public j()V
    .locals 3

    invoke-direct {p0}, Lio/flutter/embedding/engine/c;->s()Z

    move-result v0

    if-eqz v0, :cond_2

    const-string v0, "FlutterEngineConnectionRegistry#detachFromActivity"

    invoke-static {v0}, Lp0/f;->f(Ljava/lang/String;)Lp0/f;

    move-result-object v0

    :try_start_0
    iget-object v1, p0, Lio/flutter/embedding/engine/c;->d:Ljava/util/Map;

    invoke-interface {v1}, Ljava/util/Map;->values()Ljava/util/Collection;

    move-result-object v1

    invoke-interface {v1}, Ljava/util/Collection;->iterator()Ljava/util/Iterator;

    move-result-object v1

    :goto_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_0

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lc0/a;

    invoke-interface {v2}, Lc0/a;->c()V

    goto :goto_0

    :cond_0
    invoke-direct {p0}, Lio/flutter/embedding/engine/c;->m()V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    if-eqz v0, :cond_3

    invoke-virtual {v0}, Lp0/f;->close()V

    goto :goto_2

    :catchall_0
    move-exception v1

    if-eqz v0, :cond_1

    :try_start_1
    invoke-virtual {v0}, Lp0/f;->close()V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    goto :goto_1

    :catchall_1
    move-exception v0

    invoke-virtual {v1, v0}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :cond_1
    :goto_1
    throw v1

    :cond_2
    const-string v0, "FlutterEngineCxnRegstry"

    const-string v1, "Attempted to detach plugins from an Activity when no Activity was attached."

    invoke-static {v0, v1}, Lw/b;->b(Ljava/lang/String;Ljava/lang/String;)V

    :cond_3
    :goto_2
    return-void
.end method

.method public l()V
    .locals 2

    const-string v0, "FlutterEngineCxnRegstry"

    const-string v1, "Destroying."

    invoke-static {v0, v1}, Lw/b;->f(Ljava/lang/String;Ljava/lang/String;)V

    invoke-direct {p0}, Lio/flutter/embedding/engine/c;->n()V

    invoke-virtual {p0}, Lio/flutter/embedding/engine/c;->y()V

    return-void
.end method

.method public o()V
    .locals 3

    invoke-direct {p0}, Lio/flutter/embedding/engine/c;->t()Z

    move-result v0

    if-eqz v0, :cond_2

    const-string v0, "FlutterEngineConnectionRegistry#detachFromBroadcastReceiver"

    invoke-static {v0}, Lp0/f;->f(Ljava/lang/String;)Lp0/f;

    move-result-object v0

    :try_start_0
    iget-object v1, p0, Lio/flutter/embedding/engine/c;->j:Ljava/util/Map;

    invoke-interface {v1}, Ljava/util/Map;->values()Ljava/util/Collection;

    move-result-object v1

    invoke-interface {v1}, Ljava/util/Collection;->iterator()Ljava/util/Iterator;

    move-result-object v1

    :goto_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_0

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ld0/a;

    invoke-interface {v2}, Ld0/a;->b()V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    :cond_0
    if-eqz v0, :cond_3

    invoke-virtual {v0}, Lp0/f;->close()V

    goto :goto_2

    :catchall_0
    move-exception v1

    if-eqz v0, :cond_1

    :try_start_1
    invoke-virtual {v0}, Lp0/f;->close()V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    goto :goto_1

    :catchall_1
    move-exception v0

    invoke-virtual {v1, v0}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :cond_1
    :goto_1
    throw v1

    :cond_2
    const-string v0, "FlutterEngineCxnRegstry"

    const-string v1, "Attempted to detach plugins from a BroadcastReceiver when no BroadcastReceiver was attached."

    invoke-static {v0, v1}, Lw/b;->b(Ljava/lang/String;Ljava/lang/String;)V

    :cond_3
    :goto_2
    return-void
.end method

.method public p()V
    .locals 3

    invoke-direct {p0}, Lio/flutter/embedding/engine/c;->u()Z

    move-result v0

    if-eqz v0, :cond_2

    const-string v0, "FlutterEngineConnectionRegistry#detachFromContentProvider"

    invoke-static {v0}, Lp0/f;->f(Ljava/lang/String;)Lp0/f;

    move-result-object v0

    :try_start_0
    iget-object v1, p0, Lio/flutter/embedding/engine/c;->l:Ljava/util/Map;

    invoke-interface {v1}, Ljava/util/Map;->values()Ljava/util/Collection;

    move-result-object v1

    invoke-interface {v1}, Ljava/util/Collection;->iterator()Ljava/util/Iterator;

    move-result-object v1

    :goto_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_0

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Le0/a;

    invoke-interface {v2}, Le0/a;->a()V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    :cond_0
    if-eqz v0, :cond_3

    invoke-virtual {v0}, Lp0/f;->close()V

    goto :goto_2

    :catchall_0
    move-exception v1

    if-eqz v0, :cond_1

    :try_start_1
    invoke-virtual {v0}, Lp0/f;->close()V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    goto :goto_1

    :catchall_1
    move-exception v0

    invoke-virtual {v1, v0}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :cond_1
    :goto_1
    throw v1

    :cond_2
    const-string v0, "FlutterEngineCxnRegstry"

    const-string v1, "Attempted to detach plugins from a ContentProvider when no ContentProvider was attached."

    invoke-static {v0, v1}, Lw/b;->b(Ljava/lang/String;Ljava/lang/String;)V

    :cond_3
    :goto_2
    return-void
.end method

.method public q()V
    .locals 3

    invoke-direct {p0}, Lio/flutter/embedding/engine/c;->v()Z

    move-result v0

    if-eqz v0, :cond_2

    const-string v0, "FlutterEngineConnectionRegistry#detachFromService"

    invoke-static {v0}, Lp0/f;->f(Ljava/lang/String;)Lp0/f;

    move-result-object v0

    :try_start_0
    iget-object v1, p0, Lio/flutter/embedding/engine/c;->h:Ljava/util/Map;

    invoke-interface {v1}, Ljava/util/Map;->values()Ljava/util/Collection;

    move-result-object v1

    invoke-interface {v1}, Ljava/util/Collection;->iterator()Ljava/util/Iterator;

    move-result-object v1

    :goto_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_0

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lg0/a;

    invoke-interface {v2}, Lg0/a;->a()V

    goto :goto_0

    :cond_0
    const/4 v1, 0x0

    iput-object v1, p0, Lio/flutter/embedding/engine/c;->i:Landroid/app/Service;
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    if-eqz v0, :cond_3

    invoke-virtual {v0}, Lp0/f;->close()V

    goto :goto_2

    :catchall_0
    move-exception v1

    if-eqz v0, :cond_1

    :try_start_1
    invoke-virtual {v0}, Lp0/f;->close()V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    goto :goto_1

    :catchall_1
    move-exception v0

    invoke-virtual {v1, v0}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :cond_1
    :goto_1
    throw v1

    :cond_2
    const-string v0, "FlutterEngineCxnRegstry"

    const-string v1, "Attempted to detach plugins from a Service when no Service was attached."

    invoke-static {v0, v1}, Lw/b;->b(Ljava/lang/String;Ljava/lang/String;)V

    :cond_3
    :goto_2
    return-void
.end method

.method public r(Ljava/lang/Class;)Z
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/Class<",
            "+",
            "Lb0/a;",
            ">;)Z"
        }
    .end annotation

    iget-object v0, p0, Lio/flutter/embedding/engine/c;->a:Ljava/util/Map;

    invoke-interface {v0, p1}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result p1

    return p1
.end method

.method public w(Ljava/lang/Class;)V
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/Class<",
            "+",
            "Lb0/a;",
            ">;)V"
        }
    .end annotation

    iget-object v0, p0, Lio/flutter/embedding/engine/c;->a:Ljava/util/Map;

    invoke-interface {v0, p1}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lb0/a;

    if-nez v0, :cond_0

    return-void

    :cond_0
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "FlutterEngineConnectionRegistry#remove "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/Class;->getSimpleName()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Lp0/f;->f(Ljava/lang/String;)Lp0/f;

    move-result-object v1

    :try_start_0
    instance-of v2, v0, Lc0/a;

    if-eqz v2, :cond_2

    invoke-direct {p0}, Lio/flutter/embedding/engine/c;->s()Z

    move-result v2

    if-eqz v2, :cond_1

    move-object v2, v0

    check-cast v2, Lc0/a;

    invoke-interface {v2}, Lc0/a;->c()V

    :cond_1
    iget-object v2, p0, Lio/flutter/embedding/engine/c;->d:Ljava/util/Map;

    invoke-interface {v2, p1}, Ljava/util/Map;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    :cond_2
    instance-of v2, v0, Lg0/a;

    if-eqz v2, :cond_4

    invoke-direct {p0}, Lio/flutter/embedding/engine/c;->v()Z

    move-result v2

    if-eqz v2, :cond_3

    move-object v2, v0

    check-cast v2, Lg0/a;

    invoke-interface {v2}, Lg0/a;->a()V

    :cond_3
    iget-object v2, p0, Lio/flutter/embedding/engine/c;->h:Ljava/util/Map;

    invoke-interface {v2, p1}, Ljava/util/Map;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    :cond_4
    instance-of v2, v0, Ld0/a;

    if-eqz v2, :cond_6

    invoke-direct {p0}, Lio/flutter/embedding/engine/c;->t()Z

    move-result v2

    if-eqz v2, :cond_5

    move-object v2, v0

    check-cast v2, Ld0/a;

    invoke-interface {v2}, Ld0/a;->b()V

    :cond_5
    iget-object v2, p0, Lio/flutter/embedding/engine/c;->j:Ljava/util/Map;

    invoke-interface {v2, p1}, Ljava/util/Map;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    :cond_6
    instance-of v2, v0, Le0/a;

    if-eqz v2, :cond_8

    invoke-direct {p0}, Lio/flutter/embedding/engine/c;->u()Z

    move-result v2

    if-eqz v2, :cond_7

    move-object v2, v0

    check-cast v2, Le0/a;

    invoke-interface {v2}, Le0/a;->a()V

    :cond_7
    iget-object v2, p0, Lio/flutter/embedding/engine/c;->l:Ljava/util/Map;

    invoke-interface {v2, p1}, Ljava/util/Map;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    :cond_8
    iget-object v2, p0, Lio/flutter/embedding/engine/c;->c:Lb0/a$b;

    invoke-interface {v0, v2}, Lb0/a;->a(Lb0/a$b;)V

    iget-object v0, p0, Lio/flutter/embedding/engine/c;->a:Ljava/util/Map;

    invoke-interface {v0, p1}, Ljava/util/Map;->remove(Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    if-eqz v1, :cond_9

    invoke-virtual {v1}, Lp0/f;->close()V

    :cond_9
    return-void

    :catchall_0
    move-exception p1

    if-eqz v1, :cond_a

    :try_start_1
    invoke-virtual {v1}, Lp0/f;->close()V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    goto :goto_0

    :catchall_1
    move-exception v0

    invoke-virtual {p1, v0}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :cond_a
    :goto_0
    throw p1
.end method

.method public x(Ljava/util/Set;)V
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/Set<",
            "Ljava/lang/Class<",
            "+",
            "Lb0/a;",
            ">;>;)V"
        }
    .end annotation

    invoke-interface {p1}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object p1

    :goto_0
    invoke-interface {p1}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_0

    invoke-interface {p1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Class;

    invoke-virtual {p0, v0}, Lio/flutter/embedding/engine/c;->w(Ljava/lang/Class;)V

    goto :goto_0

    :cond_0
    return-void
.end method

.method public y()V
    .locals 2

    new-instance v0, Ljava/util/HashSet;

    iget-object v1, p0, Lio/flutter/embedding/engine/c;->a:Ljava/util/Map;

    invoke-interface {v1}, Ljava/util/Map;->keySet()Ljava/util/Set;

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/util/HashSet;-><init>(Ljava/util/Collection;)V

    invoke-virtual {p0, v0}, Lio/flutter/embedding/engine/c;->x(Ljava/util/Set;)V

    iget-object v0, p0, Lio/flutter/embedding/engine/c;->a:Ljava/util/Map;

    invoke-interface {v0}, Ljava/util/Map;->clear()V

    return-void
.end method
