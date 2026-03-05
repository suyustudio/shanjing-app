.class public final synthetic Lio/flutter/view/f;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lp0/e;


# instance fields
.field public final synthetic a:Lio/flutter/view/h$l;


# direct methods
.method public synthetic constructor <init>(Lio/flutter/view/h$l;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lio/flutter/view/f;->a:Lio/flutter/view/h$l;

    return-void
.end method


# virtual methods
.method public final test(Ljava/lang/Object;)Z
    .locals 1

    iget-object v0, p0, Lio/flutter/view/f;->a:Lio/flutter/view/h$l;

    check-cast p1, Lio/flutter/view/h$l;

    invoke-static {v0, p1}, Lio/flutter/view/h;->b(Lio/flutter/view/h$l;Lio/flutter/view/h$l;)Z

    move-result p1

    return p1
.end method
