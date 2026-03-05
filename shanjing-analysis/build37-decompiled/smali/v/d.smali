.class public final synthetic Lv/d;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic d:Lv/f;


# direct methods
.method public synthetic constructor <init>(Lv/f;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lv/d;->d:Lv/f;

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 1

    iget-object v0, p0, Lv/d;->d:Lv/f;

    invoke-static {v0}, Lv/f;->a(Lv/f;)V

    return-void
.end method
