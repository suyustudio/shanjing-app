.class Lio/flutter/embedding/android/s$c;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lio/flutter/embedding/engine/renderer/a;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/flutter/embedding/android/s;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic a:Lio/flutter/embedding/android/s;


# direct methods
.method constructor <init>(Lio/flutter/embedding/android/s;)V
    .locals 0

    iput-object p1, p0, Lio/flutter/embedding/android/s$c;->a:Lio/flutter/embedding/android/s;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public c()V
    .locals 2

    iget-object v0, p0, Lio/flutter/embedding/android/s$c;->a:Lio/flutter/embedding/android/s;

    const/4 v1, 0x0

    invoke-static {v0, v1}, Lio/flutter/embedding/android/s;->g(Lio/flutter/embedding/android/s;Z)Z

    iget-object v0, p0, Lio/flutter/embedding/android/s$c;->a:Lio/flutter/embedding/android/s;

    invoke-static {v0}, Lio/flutter/embedding/android/s;->h(Lio/flutter/embedding/android/s;)Ljava/util/Set;

    move-result-object v0

    invoke-interface {v0}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v0

    :goto_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    if-eqz v1, :cond_0

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lio/flutter/embedding/engine/renderer/a;

    invoke-interface {v1}, Lio/flutter/embedding/engine/renderer/a;->c()V

    goto :goto_0

    :cond_0
    return-void
.end method

.method public f()V
    .locals 2

    iget-object v0, p0, Lio/flutter/embedding/android/s$c;->a:Lio/flutter/embedding/android/s;

    const/4 v1, 0x1

    invoke-static {v0, v1}, Lio/flutter/embedding/android/s;->g(Lio/flutter/embedding/android/s;Z)Z

    iget-object v0, p0, Lio/flutter/embedding/android/s$c;->a:Lio/flutter/embedding/android/s;

    invoke-static {v0}, Lio/flutter/embedding/android/s;->h(Lio/flutter/embedding/android/s;)Ljava/util/Set;

    move-result-object v0

    invoke-interface {v0}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v0

    :goto_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    if-eqz v1, :cond_0

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lio/flutter/embedding/engine/renderer/a;

    invoke-interface {v1}, Lio/flutter/embedding/engine/renderer/a;->f()V

    goto :goto_0

    :cond_0
    return-void
.end method
